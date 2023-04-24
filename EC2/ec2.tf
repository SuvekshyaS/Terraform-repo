#Define the provider
provider "aws" {
  region = "us-east-1"
}

#Create a virtual network
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My_VPC"
  }
}

#Create a subnet
resource "aws_subnet" "my_subnet" {
  tags = {
    Name = "App_Subnet"
  }
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  depends_on              = [aws_vpc.my_vpc]
}

#Create Routing table
resource "aws_route_table" "my_route_table" {
  tags = {
    Name = "My_route_table"
  }
  vpc_id = aws_vpc.my_vpc.id
}

#Associate subnet with routing table
resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

#Create Internet Gateway
resource "aws_internet_gateway" "my_IG" {
  tags = {
    Name = "my_IG"
  }
  vpc_id     = aws_vpc.my_vpc.id
  depends_on = [aws_vpc.my_vpc]
}

#Add default route in routing table to point to Internet Gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_IG.id
}

#Create your webserver instance
resource "aws_instance" "Web" {
  ami           = "ami-06e46074ae430fba6"
  instance_type = "t2.micro"
  tags = {
    Name = "Web_server-${count.index + 1}"
  }
  count     = 3
  subnet_id = aws_subnet.my_subnet.id
}
