provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "instance-1" {
    ami = "ami-066784287e358dad1"
    instance_type = "t2.micro"
    count = "1"
    security_groups = ["default"]
    key_name = "project"
    user_data = file("server-script.sh")
    tags = {
      Name = "CI-INTGRATION"
    }
}

resource "aws_instance" "instance-2" {
    ami = "ami-066784287e358dad1"
    instance_type = "t2.micro"
    count = "1"
    security_groups = ["default"]
    key_name = "project"
    user_data = file("server-docker.sh")
    tags = {
      Name = "DOCKER-SERVER"
    }
}
