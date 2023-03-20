variable "region" {
  type = string
  #default = "ap-southeast-2"
}
variable "vpc_cidr" {
  type = list(string)
 # default = "192.168.0.0/16"
}
variable "vpc_tags" {
  type = list(string)
  #default = "MYVPC"
}
variable "subnet_cidr" {
  type = list(string)
  default = [ "192.168.0.0/24" ]
}
variable "subnet_tags" {
    type = list(string)
    default = [ "publicsubnet" ]
  
}
variable "availability_zone" {
  type = list(string)
}
variable "vm_tags" {
  type = list(string)
  
}
/*variable "web_trigger" {
  type = string
  
}*/