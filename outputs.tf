output "vpcid" {
    value = aws_vpc.main[0].id
}
output "subnet_id" {
    value = aws_subnet.main[0].id
  
}
output "instance_id" {
    value = aws_instance.this[0].id
  
}