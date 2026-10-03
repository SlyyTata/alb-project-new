resource "aws_vpc" "alb_vpc" {
  cidr_block = "187.0.0.0/16"

  tags = {
    Name = "alb-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "alb_subnet" {
  count                   = 6
  vpc_id                  = aws_vpc.alb_vpc.id
  
  cidr_block              = "187.0.${count.index + 1}.0/24" 
  
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "alb-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "alb_igw" {
  vpc_id = aws_vpc.alb_vpc.id
}

resource "aws_route_table" "alb_route_table" {
  vpc_id = aws_vpc.alb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.alb_igw.id
  }
}

resource "aws_instance" "example" {
  depends_on = [aws_security_group.instance-sg]

  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.alb_subnet[0].id

  vpc_security_group_ids = [aws_security_group.instance-sg.id]

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "alb-instance"
  }
}

resource "aws_security_group" "instance-sg" {
  name        = "instance-new-sg"
  description = "Allow traffic on port 80 from ALB and SSH from anywhere"

  vpc_id = aws_vpc.alb_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-new-sg"
  description = "Allow inbound traffic on port 80 and 443"

  vpc_id = aws_vpc.alb_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb_target_group" "target_group" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.alb_vpc.id
}

resource "aws_lb" "load_balancer" {
  depends_on         = [aws_security_group.alb_sg]

  name               = "slyy-new-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  
  subnets            = aws_subnet.alb_subnet[*].id

  enable_deletion_protection = false
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}