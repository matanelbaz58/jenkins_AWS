provider "aws" {
  region = "us-east-1"
}

# 1. יצירת VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "k8s-vpc" }
}

# 2. יצירת Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8s_vpc.id
}

# 3. יצירת Subnet
resource "aws_subnet" "k8s_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # קריטי כדי שיהיה להם IP ציבורי
  availability_zone = "us-east-1a"
}

# 4. יצירת Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.rt.id
}

# 5. Security Group ל-K8s
resource "aws_security_group" "k8s_sg" {
  vpc_id = aws_vpc.k8s_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # פתיחה חופשית לצרכי למידה/K8s
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# 6. יצירת 3 מופעי EC2
resource "aws_instance" "k8s_nodes" {
  count                  = 3
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.k8s_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  
  # הוסף את השורה הזו כדי שהמכונות יקבלו את מפתח ה-SSH של המעבדה!
  key_name               = "vockey"

  user_data = <<-EOF
              #!/bin/bash
              # 1. הכנת המערכת
              swapoff -a
              ...
              EOF

  tags = {
    Name = "k8s-node-${count.index + 1}"
  }
}
resource "local_file" "inventory" {
  content = templatefile("inventory.tpl", {
    master_ip = aws_instance.k8s_nodes[0].public_ip
    worker_ips = [aws_instance.k8s_nodes[1].public_ip, aws_instance.k8s_nodes[2].public_ip]
  })
  filename = "inventory.ini"
}
