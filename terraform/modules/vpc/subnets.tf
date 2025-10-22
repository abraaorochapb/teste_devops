###################
# Public Subnets #
###################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = var.vpc_public_subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.project_name}-rt-public" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt_public_subnets" {
  count          = var.vpc_public_subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.rt_public.id
}

###################
# Private Subnets #
###################
resource "aws_eip" "eip_nat" {
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project_name}-eip-nat"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = aws_subnet.public_subnets[0].id
  allocation_id = aws_eip.eip_nat.id

  tags = {
    Name = "${var.project_name}-nat"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.vpc_private_subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.vpc_public_subnet_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.project_name}-rt-private"
  }
}

resource "aws_route_table_association" "rt_private_subnets" {
  count          = var.vpc_private_subnet_count
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.rt_private.id
}
