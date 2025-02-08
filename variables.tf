

variable "env" {
 description = "The environment of the AWS infrastructure"
 type        = string
 default     = "dev"
}

variable "key_name" {
  description = "The keypair to use"
  type = string
  default = "ky_keypair"
}

variable "vpc_name" {
 description = "The VPC Name to use"
 type        = string
 default     = "ky-tf-vpc"
}

variable "subnet_1" {
 description = "The subnet Name to use"
 type        = string
 default     = "ky-tf-public-subnet-1a"
}

variable "subnet_2" {
 description = "The subnet Name to use"
 type        = string
 default     = "ky-tf-public-subnet-1b"
}

variable "security_groupname" {
  description = "The Security Group name to use"
  type = string
  default = "ky-tf-terra-SG"
}
