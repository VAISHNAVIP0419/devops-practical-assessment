# Terraform AWS Infrastructure Guide

This document provides a comprehensive overview of the Terraform infrastructure modules in `tf-aws-infra`.

---

## Table of Contents

1. [Module Structure](#module-structure)
2. [File Descriptions](#file-descriptions)
3. [Deployment Flow](#deployment-flow)
4. [How to Deploy](#how-to-deploy)

---

##  Module Structure

### Core Modules:

```
tf-aws-infra/
├── main.tf                   # Main configuration - calls all modules
├── variables.tf              # Input variables for main config
├── outputs.tf                # Output exports
├── provider.tf               # Terraform & provider configuration
├── INFRASTRUCTURE_GUIDE.md   # This file
│
└── modules/
    ├── vpc/                  # Virtual Private Cloud networking
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── keypair/              # EC2 SSH key pairs
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ec2/                  # EC2 instances
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── iam/                  # IAM roles & instance profiles
    │   ├── main.tf
    │   ├── variable.tf
    │   └── outputs.tf
    │
    ├── ebs/                  # EBS volumes & snapshots
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── s3/                   # S3 bucket storage
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

##  File Descriptions

### Root Level Files

#### **provider.tf**
- **Purpose**: Configure Terraform and AWS providers
- **Key Sections**:
  - Terraform version requirement (>= 1.5.0)
  - Required providers: AWS, TLS, Random
  - AWS provider region configuration

#### **variables.tf**
- **Purpose**: Define all input variables
- **Key Variables**:
  - `aws_region`: AWS region (default: ap-south-1)
  - `vpc_cidr`: VPC CIDR block (10.0.0.0/16)
  - `public_subnets`: 2 public subnets for bastion
  - `private_subnets`: 4 private subnets for apps
  - `create_keypair`: Create new or use existing key
  - `create_natgateway`: Enable NAT for private subnets
  - `common_tags`: Tags applied to all resources

#### **main.tf**
- **Purpose**: Orchestrate all modules
- **Modules Called** (in order):
  1. **VPC** - Network infrastructure
  2. **Keypair** - SSH key management
  3. **S3** - Terraform state storage
  4. **IAM** - EC2 role with S3 access
  5. **EBS** - Storage volume & backup
  6. **EC2 App** - Main application instance
  7. **EC2 Bastion** - Jump host for SSH access

#### **outputs.tf**
- **Purpose**: Export resource information
- **Key Outputs**:
  - S3 bucket name
  - EC2 instance info (app & bastion)
  - EBS volume and snapshot IDs
  - Keypair information
  - VPC and networking details

---

### Module: VPC

**Purpose**: Creates the network infrastructure foundation

#### **main.tf** - Creates:
- **VPC**: Base network with DNS enabled
- **Internet Gateway**: Routes public traffic to internet
- **Public Subnets** (2): For bastion host with auto public IP
- **Private Subnets** (4): For application with NAT access
- **NAT Gateway**: Enables private subnet outbound internet
- **Route Tables**: Public (→ IGW) and Private (→ NAT)
- **Security Groups**: App (all outbound) and Bastion (SSH only)

#### **variables.tf** - Parameters:
- `name_prefix`: Resource naming prefix
- `cidr`: VPC CIDR block
- `azs`: Availability zones list
- `public_subnets`: Public subnet CIDRs
- `private_subnets`: Private subnet CIDRs
- `create_natgateway`: Enable/disable NAT

#### **outputs.tf** - Exports:
- `vpc_id`: VPC identifier
- `public_subnet_ids`: Public subnets for bastion
- `private_subnet_ids`: Private subnets for app
- `nat_gateway_id`: NAT identifier
- `sg_app_id`: App security group
- `bastion_sg_id`: Bastion security group

---

### Module: Keypair

**Purpose**: Manage EC2 SSH key pairs

#### **main.tf** - Creates:
- **TLS Private Key**: Generates RSA 4096-bit key
- **Random Suffix**: Ensures unique key names
- **AWS Key Pair**: Imports public key to AWS

#### **variables.tf** - Parameters:
- `create_key`: Create new or use existing
- `existing_key`: Pre-existing key name
- `name_prefix`: Prefix for new key names
- `tags`: Resource tags

#### **outputs.tf** - Exports:
- `key_name`: Key pair name (new or existing)
- `private_key_pem`: Private key (only for new keys)

---

### Module: EC2

**Purpose**: Launch EC2 instances

#### **main.tf** - Creates:
- **EC2 Instance**: Configurable for different purposes
  - t3.medium for app instance
  - t2.micro for bastion host
- **EBS Attachment**: Optional volume attachment

#### **variables.tf** - Parameters:
- `name`: Instance name
- `ami`: Amazon Machine Image ID
- `instance_type`: t3.medium, t2.micro, etc.
- `subnet_id`: VPC subnet for deployment
- `security_group_ids`: Network access rules
- `key_name`: SSH key pair
- `instance_profile_name`: IAM role (for S3 access)
- `attach_ebs`: Attach volume (true/false)
- `ebs_volume_id`: Volume to attach

#### **outputs.tf** - Exports:
- `instance`: Complete instance details (ID, IPs, key name)

---

### Module: IAM

**Purpose**: Control EC2 access to AWS services

#### **main.tf** - Creates:
- **IAM Role**: Defines permissions
  - Trust: Allows EC2 service to assume role
  - Policy: S3 GetObject & PutObject permissions
- **Instance Profile**: Attaches role to EC2

#### **variables.tf** - Parameters:
- `name_prefix`: Naming prefix
- `bucket_name`: S3 bucket name
- `bucket_arn`: S3 bucket ARN (primary param)
- `s3_bucket_arn`: Alternative bucket ARN
- `tags`: Resource tags

#### **outputs.tf** - Exports:
- `role_arn`: IAM role ARN
- `instance_profile_arn`: Profile ARN
- `instance_profile_name`: Profile name (used by EC2)

---

### Module: EBS

**Purpose**: Persistent block storage

#### **main.tf** - Creates:
- **EBS Volume**: storage in specified AZ
- **EBS Snapshot**: Point-in-time backup

#### **variables.tf** - Parameters:
- `availability_zone`: AZ for volume creation
- `size_gb`: Volume size
- `tags`: Resource tags

#### **outputs.tf** - Exports:
- `volume_id`: EBS volume identifier
- `snapshot_id`: Snapshot identifier

---

### Module: S3

**Purpose**: Object storage for Terraform state

#### **main.tf** - Creates:
- **Random Suffix**: Unique bucket names
- **S3 Bucket**: Auto-generated or custom name
- **Bucket Versioning**: Protects against deletion

#### **variables.tf** - Parameters:
- `bucket_prefix`: Naming prefix
- `bucket_name`: Custom name (optional)
- `force_destroy`: Allow deletion of non-empty bucket
- `versioning`: Enable version history
- `tags`: Resource tags

#### **outputs.tf** - Exports:
- `bucket_name`: S3 bucket name
- `bucket_arn`: Bucket ARN (for IAM policies)

---

##  Deployment Flow

### Dependency Chain:
```
1. VPC Module
   ├─ Creates: VPC, Subnets, IGW, NAT, Route Tables
   └─ Outputs: VPC ID, Subnet IDs, Security Groups

2. Keypair Module
   ├─ Creates: SSH key pair
   └─ Outputs: Key name

3. S3 Module
   ├─ Creates: S3 bucket with versioning
   └─ Outputs: Bucket name, ARN

4. IAM Module
   ├─ Depends on: S3 (bucket ARN)
   ├─ Creates: Role, Policy, Instance Profile
   └─ Outputs: Instance profile name

5. EBS Module
   ├─ Creates: 8GB volume, snapshot
   └─ Outputs: Volume ID, Snapshot ID

6. EC2 App Instance
   ├─ Depends on: VPC, Keypair, IAM, EBS
   ├─ Launches in: Private subnet
   ├─ Attached: EBS volume, IAM role
   └─ Access: Via bastion host

7. EC2 Bastion Instance
   ├─ Depends on: VPC, Keypair
   ├─ Launches in: Public subnet
   └─ Access: Direct SSH from internet (port 22)
```

---

##  How to Deploy

### Prerequisites:
- AWS account with credentials configured
- Terraform >= 1.5.0 installed
- AWS CLI configured

### Step 1: Initialize Terraform
```bash
cd tf-aws-infra
terraform init
```

### Step 2: Review Configuration
```bash
terraform plan
```

### Step 3: Deploy Infrastructure
```bash
terraform apply
```

### Step 4: View Outputs
```bash
terraform output
```

### Access Instances:

**Via Bastion:**
```bash
# 1. SSH to bastion host
ssh -i your-key.pem ec2-user@<BASTION_PUBLIC_IP>

# 2. From bastion, SSH to app instance
ssh -i your-key.pem ec2-user@<APP_PRIVATE_IP>
```

### Cleanup:
```bash
terraform destroy
```
---

## Variable Customization

Edit `variables.tf` to customize:

```terraform
# Change AWS region
variable "aws_region" {
  default = "us-east-1"  # Instead of ap-south-1
}

# Customize VPC CIDR
variable "vpc_cidr" {
  default = "192.168.0.0/16"  # Different IP range
}

# Add custom subnets
variable "private_subnets" {
  default = [
    "192.168.10.0/24",
    "192.168.11.0/24",
    # ... more subnets
  ]
}

# Restrict SSH access
variable "ssh_cidr" {
  default = "YOUR.IP.ADDRESS/32"  # Your office IP only
}

# Use existing key
variable "create_keypair" {
  default = false
}

variable "existing_key_name" {
  default = "your-existing-key"
}
```

---


##  Troubleshooting

| Issue | Solution |
|-------|----------|
| S3 bucket name already exists | Change `bucket_prefix` or provide custom `create_bucket_name` |
| Key pair already exists | Set `create_keypair = false` and provide `existing_key_name` |
| Cannot SSH to bastion | Check security group allows port 22, verify key file permissions |
| Cannot reach app from bastion | Verify app security group has app port inbound from bastion SG |

---

