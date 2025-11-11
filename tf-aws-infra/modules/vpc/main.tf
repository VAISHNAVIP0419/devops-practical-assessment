# ---------------- VPC ----------------
resource "aws_vpc" "this" {
  cidr_block           = var.cidr                # VPC CIDR range
  enable_dns_support   = true                    # Enable DNS resolution
  enable_dns_hostnames = true                    # Allow hostname mapping
  tags = merge(var.tags, { Name = var.name_prefix })
}

# ---------------- Internet Gateway ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id                       # Attach to VPC
  tags   = { Name = "${var.name_prefix}-igw" }   # Name tag
}

# ---------------- Public Subnets ----------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)         # Create multiple subnets
  vpc_id                  = aws_vpc.this.id                    # Belongs to this VPC
  cidr_block              = var.public_subnets[count.index]    # CIDR from variable list
  availability_zone       = var.azs[count.index % length(var.azs)]  # Spread across AZs
  map_public_ip_on_launch = true                                # Auto public IP
  tags = merge(var.tags, { Name = "${var.name_prefix}-public-${count.index + 1}" })
}

# ---------------- Private Subnets ----------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)              # Multiple private subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]         # Private CIDR block
  availability_zone = var.azs[count.index % length(var.azs)]   # Spread evenly across AZs
  tags = merge(var.tags, { Name = "${var.name_prefix}-private-${count.index + 1}" })
}

# ---------------- Elastic IP for NAT ----------------
resource "aws_eip" "nat" {
  count  = var.create_natgateway ? 1 : 0          # Only if NAT enabled
  domain = "vpc"                                 # EIP for VPC use
  tags   = merge(var.tags, { Name = "${var.name_prefix}-nat-eip" })
}

# ---------------- NAT Gateway ----------------
resource "aws_nat_gateway" "nat" {
  count         = var.create_natgateway ? 1 : 0   # Conditional NAT creation
  allocation_id = aws_eip.nat[0].id               # Use above EIP
  subnet_id     = aws_subnet.public[0].id         # In first public subnet
  tags          = merge(var.tags, { Name = "${var.name_prefix}-nat" })
  depends_on    = [aws_internet_gateway.igw]      # IGW must exist first
}

# ---------------- Public Route Table ----------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"                      # All internet traffic
    gateway_id = aws_internet_gateway.igw.id      # Go via IGW
  }
  tags = { Name = "${var.name_prefix}-public-rt" }
}

# ---------------- Public Route Table Associations ----------------
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)      # Associate each public subnet
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------------- Private Route Table ----------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  dynamic "route" {
    for_each = var.create_natgateway ? [1] : []   # Add route only if NAT true
    content {
      cidr_block     = "0.0.0.0/0"                # Outbound internet
      nat_gateway_id = aws_nat_gateway.nat[0].id  # Through NAT Gateway
    }
  }
  tags = { Name = "${var.name_prefix}-private-rt" }
}

# ---------------- Private Route Table Associations ----------------
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)     # Link each private subnet
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ---------------- Default Security Group ----------------
resource "aws_security_group" "default" {
  name        = "${var.name_prefix}-default-sg"
  description = "Default SG for app instances"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0                               # Allow all ports
    to_port     = 0
    protocol    = "-1"                            # All protocols
    cidr_blocks = ["0.0.0.0/0"]                   # Outbound anywhere
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-default-sg" })
}

# ---------------- Bastion Security Group ----------------
resource "aws_security_group" "bastion" {
  name        = "${var.name_prefix}-bastion-sg"
  description = "SSH access to bastion host"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 22                              # SSH port open
    to_port     = 22
    protocol    = "tcp"                           # TCP traffic
    cidr_blocks = ["0.0.0.0/0"]                   # Open to all (restrict later)
  }

  egress {
    from_port   = 0                               # Allow all outbound
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-bastion-sg" })
}