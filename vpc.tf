data "aws_vpc" "existing_vpc" {
 filter {
   name   = "tag:Name"
   values = [var.vpc_name]
 }
}

data "aws_subnet" "subnet_1" {
 filter {
   name   = "tag:Name"
   values = [var.subnet_1]
 }
}

data "aws_subnet" "subnet_2" {
 filter {
   name   = "tag:Name"
   values = [var.subnet_2]
 }
}

data "aws_security_group" "existing_sg" {
  name = var.security_groupname
}