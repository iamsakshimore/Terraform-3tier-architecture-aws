variable "region" {
    default ="us-east-1"
}
variable "az1" {
    default = "us-east-1a"
  
}
variable "az3" {
    default = "us-east-1b"
  
}
variable "az2" {
    default = "us-east-1c"
}
variable "vpc_cidr" {
    default = "10.0.0.0/16"
}
variable "private_cidr" {
    default ="10.0.0.0/20" 
}
variable "private_cidr1" {
    default ="10.0.32.0/20" 
}
variable "public_cidr" {
    default = "10.0.16.0/20"
  
}
variable "project_name" {
    default = "VPASC"
  
}
variable "igw_cidr" {
    default = "0.0.0.0/0"
}
variable "ami" {
    default ="ami-068c0051b15cdb816"
}
variable "instance_type" {
    default = "t2.micro"
  
}
variable "key" {
    default = "AWS.key"
  
}