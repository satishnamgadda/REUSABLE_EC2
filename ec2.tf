resource "aws_vpc" "main" {
  count          = length(var.vpc_cidr)
  cidr_block       = var.vpc_cidr[count.index]
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_tags[count.index]
  }
}
resource "aws_subnet" "main" {
  count       = length(var.subnet_tags)
  vpc_id      = aws_vpc.main[0].id
  #cidr_block = var.subnet_cidr[count.index]
  cidr_block  = cidrsubnet(var.vpc_cidr[0],8,count.index) 
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = var.subnet_tags[count.index]
  }
  depends_on = [
    aws_vpc.main[0]
  ]
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main[0].id

  tags = {
    Name = "igw"
  }
}
resource "aws_route_table" "example" {
  vpc_id     = aws_vpc.main[0].id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
   tags = {
    Name = "pubRT"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main[0].id
  route_table_id = aws_route_table.example.id
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
resource "aws_security_group" "allow_tls" {
  name        = "mysg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  tags = {
    Name = "mysg"
  }
}
resource "aws_instance" "this" {
  count = length(var.vm_tags)
  ami                         = "ami-0ec19a300f3097b5a"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  availability_zone           = var.availability_zone[count.index]
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.main[count.index].id
  vpc_security_group_ids      = [ "${aws_security_group.allow_tls.id}" ]
   tags = {
    Name = var.vm_tags[count.index]
  }
    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host     = aws_instance.this[0].public_ip
  }

  /*provisioner "remote-exec" {
     connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host     = aws_instance.this[0].public_ip
  }
    inline = [
      "sudo apt update",
      "sudo apt install apache2 -y"
    ]
  }*/

}