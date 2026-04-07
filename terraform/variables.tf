variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"   # Free tier eligible
}

variable "key_pair_name" {
  description = "Name of the existing EC2 key pair for SSH access"
  type        = string
}

variable "project_name" {
  description = "Name tag applied to all resources"
  type        = string
  default     = "dumbbudget"
}

variable "dumbbudget_pin" {
  description = "PIN for the DumbBudget application"
  type        = string
  sensitive   = true
}