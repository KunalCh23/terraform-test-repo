resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-ig"
  }
}

resource "aws_eip" "eip" {
  vpc = true
  depends_on = [aws_internet_gateway.ig]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id = element(aws_subnet.public_subnet.*.id, 0)
  depends_on = [aws_internet_gateway.ig]

  tags = {
    Name = "${var.vpc_name}-nat"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = var.public_subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "default" {
  name        = "${var.vpc_name}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
}
