terraform {
    backend "s3" {
        bucket = "two-tier04"
        key = "terrafom.tfstate"
        region = "us-east-1" # remorte backend
    }
}
provider "aws" {
    region = var.region
}
# create a VPC
resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name="${var.project_name}-vpc"
    }
}
#create a private subnet
resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.private_cidr
    availability_zone = var.az1
    tags ={
        Name = "${var.project_name}-private-subnet"
    }  
}
#create a private subnet

resource "aws_subnet" "private-subnet1" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.private_cidr1
    availability_zone = var.az3
    tags ={
        Name = "${var.project_name}-private-subnet1"
    }  
}
# create a public subnet
resource "aws_subnet" "public-aws_subnet" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.public_cidr
    availability_zone = var.az2
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.project_name}-public-subnet"
    }
}

# create a internet Gateway

resource "aws_internet_gateway" "my_IGW" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
        Name = "${var.project_name}-IGW"
    }
}
#eip
resource "aws_eip" "my_eip" {
  #instance = aws_instance.public-server.id
  domain   = "vpc"
}
#add nat gateway
resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public-aws_subnet.id

  tags = {
    Name = "${var.project_name}-gw-NAT"
  }

  depends_on = [aws_internet_gateway.my_IGW]
}

# create defoult RT
resource "aws_default_route_table" "my-RT" {
    default_route_table_id = aws_vpc.my-vpc.default_route_table_id
    tags = {
      Name = "${var.project_name}-main-RT"
    }  
}
# add rout in main RT
resource "aws_route" "aws_route" {
  route_table_id = aws_default_route_table.my-RT.id
  destination_cidr_block = var.igw_cidr
  gateway_id = aws_internet_gateway.my_IGW.id
}
#create a security group
 resource "aws_security_group" "my-sg" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      Name = "${var.project_name}-SG"
    }
      description =  "allow sh, http, mysql traffic"

      ingress {
        protocol = "tcp"
        to_port = 22
        from_port = 22
        cidr_blocks = ["0.0.0.0/0"]
      }
      ingress {
        protocol = "tcp"
        to_port = 80
        from_port = 80
        cidr_blocks = ["0.0.0.0/0"]
      }
      ingress{
        protocol = "tcp"
        to_port = 3306
        from_port = 3306
        cidr_blocks = ["0.0.0.0/0"]    

    }
     egress {
        protocol = -1
        to_port = 0
        from_port = 0
        cidr_blocks = ["0.0.0.0/0"]
     }
     depends_on = [ aws_vpc.my-vpc ] # explicite dependency
  }
    

#create public  server for proxy-server
resource "aws_instance" "public-server" {
    subnet_id = aws_subnet.public-aws_subnet.id
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key
    vpc_security_group_ids = [ aws_security_group.my-sg.id ]
    tags = {
        Name = "${var.project_name}-proxy-server"
    }
    depends_on = [ aws_security_group.my-sg ]
}
# create a private serve for db-server
resource "aws_instance" "private-server" {
  subnet_id = aws_subnet.private-subnet.id
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key
  vpc_security_group_ids = [ aws_security_group.my-sg.id ]
  tags = {
    Name = "${var.project_name}-db-servet"
  }
  depends_on = [ aws_security_group.my-sg ]
}
# create a private serve for app-server
resource "aws_instance" "private-server1" {
  subnet_id = aws_subnet.private-subnet1.id
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key
  vpc_security_group_ids = [ aws_security_group.my-sg.id ]
  tags = {
    Name = "${var.project_name}-app-server"
  }
  depends_on = [ aws_security_group.my-sg ]
}