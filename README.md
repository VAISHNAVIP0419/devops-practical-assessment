# Practical Assessment – End-to-End DevOps Automation

## Overview

This repository contains three practical assessment projects demonstrating common DevOps tasks:

- Infrastructure as Code (Terraform) for AWS resources
- Application deployment using Docker Compose (Superset)
- Kubernetes orchestration on EKS (3-tier MERN application)

Each section below documents the exact steps, files used, commands, and verification steps required to reproduce the work.

---

## Prerequisites

- AWS CLI configured with appropriate credentials and region (ap-south-1 used in examples)
- Terraform v1.5+ installed and in PATH
- kubectl, eksctl, helm installed for EKS tasks
- Docker and docker-compose (or Docker Compose v2) for image builds and Superset deployment
- An AWS account and permissions to create IAM roles, ECR repos, EC2, EKS, S3, and ELB
- Replace placeholder values like `<AWS_ACCOUNT_ID>`, `<dockerhub-username>`, `<Public-IP>` before running commands

---

## 1. Terraform Infrastructure (tf-aws-infra)

Objective: Create modular Terraform modules that provision the following independent components:

- VPC (custom CIDR, public + private subnets, route tables, IGW, NAT)
- Key pair (RSA key generation or import)
- Instance profile + IAM role (EC2 -> S3 access: GetObject, PutObject) and instance profile attachment
- EBS volume and automated snapshot handling
- EC2 app instance (t3.medium) with EBS attached
- EC2 bastion host (t2.micro) for SSH access
- S3 bucket for Terraform state backend (versioning enabled)


Files of interest:

- `tf-aws-infra/provider.tf` — provider settings and backend configuration
- `tf-aws-infra/variables.tf` — inputs (region, cidr, key names)
- `tf-aws-infra/main.tf` — root module wiring submodules
- `tf-aws-infra/modules/*` — modular resources (vpc, ec2, keypair, s3, iam, ebs)

Commands (example):

```powershell
cd tf-aws-infra
terraform init
terraform validate
terraform plan 
terraform apply 
```

Verify resources in AWS console and save outputs:

```powershell
terraform output > infra-outputs.txt
```

---

## 2. Superset Deployment (superset-docker-deploy)

Objective: Deploy Apache Superset onto an EC2 app instance using Docker Compose.

Requirements implemented:

- Build a custom Superset image from `apache/superset:latest` and install additional drivers (Trino, cx_Oracle/oracledb)
- Push the custom image to Docker Hub and reference it in `docker-compose.yml`
- Store Docker infra in this repo under `superset-docker-deploy/`
- Use a custom Docker network with a specific IP range (example: `172.28.0.0/16`)
- Use latest images (use `:latest` tags) and `imagePullPolicy: Always` for containers
- Use Nginx as an SSL-terminating reverse proxy (certs under `superset-docker-deploy/certs/`)
- Provide a shell script `scripts/backup.sh` to create PostgreSQL dumps and rotate backups

Key files and locations:

- `superset-docker-deploy/docker/Dockerfile` — Dockerfile that installs Trino & Oracle drivers
- `superset-docker-deploy/docker/requirements.txt` — Python packages (trino, cx_Oracle / oracledb)
- `superset-docker-deploy/compose/docker-compose.yml` — Compose file (Postgres, Superset, Nginx)
- `superset-docker-deploy/nginx/default.conf` — Reverse proxy config (HTTP→HTTPS)
- `superset-docker-deploy/certs/` — Place certs here (fullchain.pem, privkey.pem)
- `superset-docker-deploy/scripts/backup.sh` — DB backup script

Example build & push commands:

```bash
# Build custom image locally (run on EC2 or CI runner)
cd superset-docker-deploy/docker
docker build -t <dockerhub-username>/superset-custom:latest .

# Push to Docker Hub
docker login
docker push <dockerhub-username>/superset-custom:latest
```

Bring stack up on EC2 (example):

```bash
cd superset-docker-deploy/compose
docker compose pull
docker compose up -d --build
```

Docker network example (in `docker-compose.yml`):

```yaml
networks:
  superset_net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.28.0.0/16
```

Backup run (manual):

```bash
bash superset-docker-deploy/scripts/backup.sh
```

Verify Superset:

```bash
# Check containers
docker ps

# Access via https://<EC2_PUBLIC_IP>
```

---

## 3. EKS Cluster & 3-tier App Deployment (tf-aws-eks + three-tier-app)

Objective: Provision an EKS cluster (latest stable Kubernetes), enable AWS Load Balancer Controller and Cluster Autoscaler, deploy the 3-tier MERN app, and package the manifests as a Helm chart.

Files used / created:

- `tf-aws-eks/` — Terraform module for EKS cluster, node groups, and networking
- `three-tier-app/Application-Code/` — source code and Dockerfiles for backend & frontend
- `three-tier-app/Kubernetes-Manifests-file/` — manifests for DB, backend, frontend, and ingress
- `three-tier-app/helm_chart_k8s/` — Helm chart scaffold created from manifests

Terraform (EKS):

```bash
cd tf-aws-eks
terraform init
terraform plan
terraform apply
```

Configure kubeconfig and verify:

```bash
aws eks update-kubeconfig --region ap-south-1 --name tf-eks-cluster
kubectl get nodes
```

Build & push images to ECR (example):

```bash
# Login
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com

# Backend
cd three-tier-app/Application-Code/backend
docker build -t three-tier-app-backend:latest .
docker tag three-tier-app-backend:latest <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/three-tier-app-backend:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/three-tier-app-backend:latest

# Frontend
cd ../frontend
docker build -t three-tier-app-frontend:latest .
docker tag three-tier-app-frontend:latest <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/three-tier-app-frontend:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/three-tier-app-frontend:latest
```

##  Controllers Setup: ALB & Cluster Autoscaler

This step sets up the AWS Load Balancer Controller (for managing ALBs) and the Cluster Autoscaler (for automatic scaling of worker nodes).

---

### Install AWS Load Balancer Controller (IRSA)

**IRSA (IAM Roles for Service Accounts)** lets Kubernetes service accounts use specific AWS IAM roles.  
**OIDC (OpenID Connect)** is used to connect AWS IAM with your EKS cluster securely.

```bash
# Step 1: Download and create IAM policy for ALB controller
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam-policy.json

# Step 2: Connect (associate) OIDC provider to EKS cluster (for IRSA)
eksctl utils associate-iam-oidc-provider --region ap-south-1 --cluster tf-eks-cluster --approve

# Step 3: Create IAM service account for ALB controller and attach the policy
eksctl create iamserviceaccount \
  --cluster tf-eks-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve \
  --override-existing-serviceaccounts

# Step 4: Install AWS Load Balancer Controller using Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=tf-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=ap-south-1 \
  --set vpcId=<VPC_ID>

Create namespace & image pull secret:

```bash
kubectl create namespace three-tier
kubectl create secret docker-registry ecr-registry-secret --namespace three-tier --docker-server=<AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com --docker-username=AWS --docker-password=$(aws ecr get-login-password --region ap-south-1)
```

Deploy manifests:

```bash
kubectl apply -f three-tier-app/Kubernetes-Manifests-file/Database/
kubectl apply -f three-tier-app/Kubernetes-Manifests-file/Backend/
kubectl apply -f three-tier-app/Kubernetes-Manifests-file/Frontend/
kubectl apply -f three-tier-app/Kubernetes-Manifests-file/ingress.yaml
```

Create a Helm chart (packaging step):

```bash
helm create three-tier-chart
# Copy and parameterize manifests into three-tier-chart/templates/
helm lint three-tier-chart
helm install three-tier-app ./three-tier-chart --ns three-tier
```

Verify ALB and application:

```bash
kubectl get ingress -n three-tier
```

Success criteria:

- Pods and services in `three-tier` are Running
- ALB is provisioned and has a DNS/ARN
- Frontend and backend respond via ALB
- Cluster Autoscaler registers ASG and scales nodes under load


---

## Final Outcome

- Terraform modules for VPC, keypair, IAM/instance profile, EBS snapshots, EC2 app + bastion, and S3 backend were created and used to provision infrastructure.
- Superset deployed on EC2 via Docker Compose with a custom image (Trino & Oracle drivers), Nginx SSL reverse proxy, and DB backup automation.
- EKS cluster provisioned with ALB Controller and Cluster Autoscaler; 3-tier MERN app deployed and packaged as a Helm chart.
