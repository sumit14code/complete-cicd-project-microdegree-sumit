provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "instance-1" {
    ami = "ami-066784287e358dad1"
    instance_type = "t2.micro"
    count = "1"
    security_groups = ["default"]
    key_name = "kiran"
    tags = {
      Name = "grafan"
    }
}

resource "aws_instance" "instance-2" {
    ami = "ami-066784287e358dad1"
    instance_type = "t2.micro"
    count = "1"
    security_groups = ["default"]
    key_name = "kiran"
    tags = {
      Name = "Node-port"
    }
}
