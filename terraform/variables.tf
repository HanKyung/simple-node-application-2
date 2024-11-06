# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Input variable definitions
variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"

}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "ce7-ty-vpc"
}

variable "ec2_name" {
  description = "Name of EC2"
  type        = string
  default     = "stephen-ec2-for-docker"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "Instance type of EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of EC2 key pair pem file"
  type        = string
  default     = "stephen-useast1-13072024"
}

variable "subnet_name" {
  description = "Name of subnet to deploy EC2 in"
  type        = string
  default     = "stephen-vpc-tf-module-public-us-east-1a"
}

variable "sg_name" {
  description = "Name of security group to create"
  type        = string
  default     = "stephen-test-module-create-sg"
}

####################################
## ECS variables
####################################

variable "app_name" {
  description = "ecr app name"
  type        = string
  default     = "nodejs"
}

variable "app_environment" {
  description = "ecr app environment"
  type        = string
  default     = "dev"
}

variable "image_url" {
  type    = string
  default = "public.ecr.aws/sctp-sandbox/stephen-nodejs-dev-ecr:latest"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR Block for Public Subnets in VPC"
  default     = ["10.10.100.0/24", "10.10.101.0/24"]
  # default = [for subnet in range(var.vpc_public_subnet_count): cidrsubnet(var.vpc_cidr_block, 8, subnet)]
}


variable "private_subnets" {
  type        = list(string)
  description = "CIDR Block for Private Subnets in VPC"
  default     = ["10.10.0.0/24", "10.10.1.0/24"]
  # default = [for subnet in range(var.vpc_public_subnet_count): cidrsubnet(var.vpc_cidr_block, 8, subnet)]
}