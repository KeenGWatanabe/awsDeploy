Here are the best ways to check all active AWS resources in your account:

## 1. **AWS Resource Explorer (Recommended)**
The newest and most comprehensive tool from AWS:

```bash
# Enable Resource Explorer (if not already enabled)
aws resource-explorer-2 create-index

# List all resources
aws resource-explorer-2 search --query-string "*"
```

## 2. **AWS Config** (Most Comprehensive)
If AWS Config is enabled, it tracks all resources:
```bash
# List all recorded resources
aws configservice list-discovered-resources --resource-type AWS::EC2::Instance
aws configservice list-discovered-resources --resource-type AWS::S3::Bucket
# Repeat for other resource types
```

## 3. **AWS Console - Resource Groups & Tag Editor**
- Go to **AWS Console → Resource Groups & Tag Editor**
- Click **"Resource Groups"** → **"Create resource group"**
- Use **"All supported resource types"** to see everything

## 4. **Service-Specific Checks**
Check major services individually:

### **Compute & Networking:**
```bash
# EC2 Instances
aws ec2 describe-instances

# VPCs
aws ec2 describe-vpcs

# Subnets
aws ec2 describe-subnets

# Security Groups
aws ec2 describe-security-groups
```

### **Storage:**
```bash
# S3 Buckets
aws s3 ls

# EBS Volumes
aws ec2 describe-volumes
```

### **Database & Analytics:**
```bash
# RDS Instances
aws rds describe-db-instances

# DynamoDB Tables
aws dynamodb list-tables
```

### **Management & Governance:**
```bash
# CloudWatch Log Groups
aws logs describe-log-groups

# IAM Roles
aws iam list-roles

# Lambda Functions
aws lambda list-functions
```

## 5. **AWS Cost Explorer**
Check what's costing you money (often reveals hidden resources):
- AWS Console → **Cost Explorer** → **Reports**
- Look at monthly costs by service

## 6. **Third-Party Tools**
- **AWS-nuke**: Nuclear option for cleaning up everything (use with caution!)
- **CloudFormation**: Check if any stacks are running
- **Terraform**: If you used Terraform, check your state files

## Quick Check Command:
Here's a quick script to check major resources:
```bash
#!/bin/bash
echo "=== AWS RESOURCE INVENTORY ==="
echo "S3 Buckets:" && aws s3 ls
echo "EC2 Instances:" && aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId'
echo "VPCs:" && aws ec2 describe-vpcs --query 'Vpcs[].VpcId'
echo "DynamoDB Tables:" && aws dynamodb list-tables
echo "Lambda Functions:" && aws lambda list-functions --query 'Functions[].FunctionName'
```

## Important Notes:
- **Some resources are region-specific** - make sure to check all regions
- **Use AWS Resource Explorer** for the most complete picture
- **Check CloudTrail** for API activity if you suspect unknown resources

Start with **AWS Resource Explorer** or **Resource Groups** in the console for the easiest comprehensive view!