#key pair 
resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("terra-key-ec2.pub")
}

#vpc $ security group
resource "aws_default_vpc" "my_vpc" {

  tags = {
    Name = "my-vpc"
    } 
}    

resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_default_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]     
  security_group_id = aws_security_group.my_security_group.id
}    

#outbound rule to allow all traffic
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}   

#ec2 instance
resource "aws_instance" "my_instance" {
    ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
    instance_type = "t3.small"
    key_name      = aws_key_pair.my_key.key_name
    security_groups = [aws_security_group.my_security_group.name]

    
    tags = {
        Name = "Jenkins-terra"
    }    
}