variable "vpc_name" {
 description = "Enter VPC name"
 default = "test-vpc"
}

variable "region"{
    description = "Enter region name"
    default = "ap-south-1"
}

variable "cidr_block" {
  description = "enter vpc cidr block"
  default = "10.1.0.0/16"
}
variable "public_subnet_count" {
  description = "Number of public subnets"
  default = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  default = 2
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default = [ "10.0.1.0/24","10.0.2.0/24" ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default = [ "10.0.3.0/24","10.0.4.0/24" ]
}

variable "availability_zones" {
  description = "Availability zone for subnets"
  type        = list(string)
  default = ["ap-south-1a","ap-south-1b","ap-south-1c"]
}
