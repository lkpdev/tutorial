variable "env" {}
variable "region" {}
variable "subnet_cidrs" {}
variable "vpc_cidr" {}
variable "instance_type" {}
variable "volume_size" {}

# Variable definitions
# variable "project" {
#   type        = string
#   description = "Project name"
# }
#
# variable "environment" {
#   type        = string
#   description = "Environment name i.e. env01, env02 etc."
# }
#
# variable "location" {
#   type        = string
#   description = "Location of the Azure resources i.e. uksouth "
# }
#
# # Local variables
# locals {
#   tags = {
#     Project     = var.project
#     Environment = var.environment
#   }
# }