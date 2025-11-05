# Practical Assessment – End-to-End DevOps Automation

## Overview

This project demonstrates a complete DevOps practical assessment covering **Infrastructure as Code (Terraform)**, **Containerization (Docker)**, **Application Deployment (Superset)**, and **Orchestration (Kubernetes on EKS)**. The setup ensures full automation, modularity, scalability, and best DevOps practices.

---

## 1. Terraform Infrastructure Setup

### Objective

Automate AWS infrastructure provisioning using **Terraform** modules for:

* VPC
* Key Pair
* IAM Role and Instance Profile (EC2 to S3 access – Get/Put)
* EBS Snapshots
* EC2 Instances (App Server and Bastion Host)
* S3 Bucket for remote Terraform state storage

### Steps Performed

1. Created a modular Terraform structure under `tf-aws-infra/`:

   * **VPC Module**: Configured CIDR, subnets, route tables, and Internet Gateway.
   * **Keypair Module**: Generated and registered an AWS key pair for SSH access.
   * **IAM Module**: Defined roles, policies, and instance profiles for S3 access.
   * **EBS Module**: Created EBS volume and automated snapshot backups.
   * **EC2 Module**: Launched EC2 instance (t3.medium) with attached EBS volume.
   * **Bastion Module**: Deployed a t2.micro bastion host with restricted SSH access.
   * **S3 Module**: Used for storing Terraform state remotely.

2. **Security Group Configuration**
   Allowed only essential ports (e.g., 22, 80, 443, 8088) for secure communication.

3. **Terraform Commands Executed**

   ```
   terraform init
   terraform validate
   terraform plan
   terraform apply -auto-approve
   ```

4. Verified resources in the **AWS Management Console** — ensuring all EC2 instances, roles, and networking components were provisioned correctly.

### Outcome

* Fully modular Terraform infrastructure was deployed successfully.
* Terraform state securely stored in an **S3 backend**.
* IAM roles provided EC2 instances access to S3 with **Get** and **Put** permissions.
* Infrastructure validated and ready for Superset deployment.

---

## 2. Superset Docker Deployment

### Objective

Deploy **Apache Superset** on an EC2 instance using **Docker Compose** with custom image and SSL-secured Nginx reverse proxy.

### Steps Performed

1. **Connected to the Superset EC2 Instance**

   ```
   ssh -i "assess-key.pem" ec2-user@<Public-IP>
   ```

2. **Installed Docker and Docker Compose** on the EC2 instance.

3. **Built Custom Superset Image**

   * Used base image: `apache/superset:latest`
   * Added dependencies for **Trino** and **Oracle drivers** via `requirements.txt`
   * Built and pushed the custom image to Docker Hub:

     ```
     docker build -t <dockerhub-username>/superset-custom:latest .
     docker login
     docker push <dockerhub-username>/superset-custom:latest
     ```

4. **Docker Compose Setup**

   * Services:

     * **PostgreSQL** – metadata database
     * **Redis** – caching/message queue
     * **Superset** – custom image with extra drivers
     * **Nginx** – SSL reverse proxy
   * Configured under `superset-docker-deploy/compose/docker-compose.yml`
   * SSL certificate placed in `certs/fullchain.pem`
   * Configured **custom Docker network** with specific IP range in `docker-compose.yml`

5. **Deployed Stack**

   ```
   sudo docker compose build
   sudo docker compose up -d
   sudo docker ps
   ```

6. **Verified Deployment**

   * Accessed Superset web UI via:
     `https://<EC2-Public-IP>`
   * Confirmed HTTPS with valid SSL termination by Nginx.

7. **Database Backup Script**

   * `scripts/backup.sh` automated daily DB backups using cron.
   * Command to run manually:

     ```
     bash scripts/backup.sh
     ```

### Outcome

* Superset successfully deployed with Nginx SSL reverse proxy.
* Custom Superset image supports both Trino and Oracle connections.
* Docker network isolated for enhanced security.
* Infrastructure and configurations stored in GitHub for version control.

---

## 3. End-to-End Kubernetes 3-Tier App on EKS

### Objective

Provision an **EKS Cluster** using Terraform and deploy a **3-tier MERN application** from
[https://github.com/AmanPathak-DevOps/End-to-End-Kubernetes-Three-Tier-DevSecOps-Project](https://github.com/AmanPathak-DevOps/End-to-End-Kubernetes-Three-Tier-DevSecOps-Project)

---

### Step 1: EKS Cluster Provisioning

* Used `tf-aws-eks/` Terraform modules to create:

  * EKS Cluster (latest Kubernetes version)
  * Node Groups
  * Networking resources
* Cluster supports **autoscaling** and **ALB ingress controller**.

Commands:

```
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

---

### Step 2: Configure Kubeconfig

```
aws eks update-kubeconfig --region ap-south-1 --name shrutika-eks
kubectl get nodes
```

---

### Step 3: Application Container Images

* Built and pushed backend, frontend, and database Docker images to **ECR**:

  ```
  docker build -t three-tier-backend ./Application-Code/backend
  docker build -t three-tier-frontend ./Application-Code/frontend

  aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin <account>.dkr.ecr.ap-south-1.amazonaws.com

  docker tag three-tier-backend:latest <account>.dkr.ecr.ap-south-1.amazonaws.com/three-tier-backend:latest
  docker tag three-tier-frontend:latest <account>.dkr.ecr.ap-south-1.amazonaws.com/three-tier-frontend:latest

  docker push <account>.dkr.ecr.ap-south-1.amazonaws.com/three-tier-backend:latest
  docker push <account>.dkr.ecr.ap-south-1.amazonaws.com/three-tier-frontend:latest
  ```

---

### Step 4: Kubernetes Namespace & Secrets

```
kubectl create namespace three-tier
kubectl create secret docker-registry ecr-registry-secret \
  --namespace three-tier \
  --docker-server=<account>.dkr.ecr.ap-south-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ap-south-1)
```

---

### Step 5: Controllers Setup

**AWS Load Balancer Controller:**

```
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=shrutika-eks \
  --set serviceAccount.create=false \
  --set region=ap-south-1
```

**Cluster Autoscaler:**

```
kubectl apply -f Kubernetes-Manifests-file/cluster-autoscaler-autodiscover.yaml
kubectl -n kube-system get pods | grep cluster-autoscaler
```

---

### Step 6: Deploy Application Manifests

```
kubectl apply -f Kubernetes-Manifests-file/Database/
kubectl apply -f Kubernetes-Manifests-file/Backend/
kubectl apply -f Kubernetes-Manifests-file/Frontend/
kubectl apply -f Kubernetes-Manifests-file/ingress.yaml
```

Monitor:

```
kubectl get pods -n three-tier -w
kubectl get svc,ingress -n three-tier
```

---

### Step 7: Helm Chart Creation

```
helm create three-tier-chart
# Copied manifests into templates folder
helm lint three-tier-chart
helm install three-tier-app ./three-tier-chart
```

---

### Step 8: Validation

* Verified workloads:

  ```
  kubectl get all -n three-tier
  ```
* Confirmed **ALB ARN** from AWS console.
* Accessed frontend via ALB endpoint.
* Cluster Autoscaler successfully scaled node groups during load testing.

---

## Final Outcome

✅ **Infrastructure:** Automated and modularized using Terraform
✅ **Application:** Superset deployed with Docker Compose and SSL Nginx proxy
✅ **Orchestration:** 3-tier application deployed on EKS with autoscaling and ALB
✅ **Version Control:** All code and infra stored in GitHub
✅ **Security:** IAM roles, SG rules, SSL, and restricted SSH access implemented
✅ **Documentation:** Comprehensive README with all deployment commands


