#####################################
# AWS VARS
#####################################

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key ID"
  default     = ""
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Access Key"
  default     = ""
}

variable "vm_size" {
  type        = string
  description = "The cloud specific vm size type i.e ubuntu-20-04-x64. https://slugs.do-api.dev/. Maximum allowed vm instance size is 8 CPU and 16 RAM."
  default     = "s-2vcpu-4gb"
}