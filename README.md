# AWS Infrastructure Automation with Terraform

This repository contains **Terraform configurations to provision an end-to-end, isolated network infrastructure** on AWS, deploying a target EC2 instance inside a custom Virtual Private Cloud (VPC). 

## 🏗️ Architecture Overview

The configuration automates the creation of the following AWS resources:
* A custom VPC with Public across availability zones, an Internet Gateway (IGW) for public routing, and Route Tables.
* Security Groups acting as virtual firewalls to regulate inbound and outbound traffic to the instance.
* A target EC2 instance provisioned inside the network layout.

## 📁 Project Structure

```text
├── main.tf          # Core infrastructure resources (VPC, Subnets, EC2)
├── providers.tf     # AWS provider configuration
└── README.md        # This file
```

## 🛠️ Prerequisites

Before executing the configuration, ensure you have the following installed and configured:
1. **Terraform CLI** (v1.2.0 or higher) -> [Install Terraform](https://hashicorp.com "Terraform Download")
2. **AWS CLI** configured with appropriate administrative permissions -> [AWS CLI Configuration](https://amazon.com "AWS CLI Configure")
3. An active **AWS Account**.

## 🚀 Deployment Workflow

Follow these steps to deploy the infrastructure:

### 1. Initialize the Workspace
Download the required AWS provider plugins and initialize the backend.
```bash
terraform init
```

### 2. Code Formatting & Validation (Optional but Recommended)
Format the configuration files properly and validate syntax correctness.
```bash
terraform fmt
terraform validate
```

### 3. Generate an Execution Plan
Review the resources that Terraform intends to create, modify or destroy.
```bash
terraform plan
```

### 4. Apply Changes
Provision the infrastructure on AWS. Review the plan once more and type `yes` when prompted to confirm.
```bash
terraform apply
```

## 📋 Inputs

### Inputs

| Name | Description | Type | Default |
|:---|:---|:---|:---|
| `aws_region` | The target AWS region for deployment | `string` | `us-east-1` |
| `vpc_cidr` | IP range block for the custom VPC | `string` | `187.0.0.0/16` |
| `instance_type` | Hardware sizing for the target EC2 instance | `string` | `t3.micro` |

## 🧹 Cleanup

To tear down all resources created by this project and avoid unexpected AWS charges, execute
```bash
terraform destroy
```
