provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "instance-1" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.medium"
  security_groups = ["default"]
  key_name = "project"
  user_data = file("server-script.sh")
  tags ={
    Name = "MASTER-SERVER"
  }
}


