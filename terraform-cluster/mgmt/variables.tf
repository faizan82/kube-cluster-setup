variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {} 
variable  "vpc_cidr" {}
variable "aws_key_path" {}
variable "aws_key_name" {}
variable "pub_inst_count" {}
variable "pri_inst_count" {}
variable "etcd_inst_count" {}

variable "public_sub_cidr" {
     default = []
}

variable "private_sub_cidr" {
     default = []
}

variable "amis_jump" {
     default = {}
 }

variable "amis_ubuntu" {
     default = {}
}

variable "amis_aws" {
     default = {}
}
