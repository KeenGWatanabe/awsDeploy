# How to reference in other places

variable "MONGODB_URI" {
  description = "MongoDB Atlas connection URI"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
}

variable "name_prefix" {
  description = "ecs for app"
  type        = string
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
  
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for DNS records"
  type        = string
}