provider "aws" {
  region = var.aws_region
}

#Cria vpc
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name     = "${var.project}-vpc"
    Ambiente = var.env
  }
}

#Subnet publica
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name     = "${var.project}-public-${element(var.azs, count.index)}"
    Ambiente = var.env
  }
}

#Subnet privada
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name     = "${var.project}-private-${element(var.azs, count.index)}"
    Ambiente = var.env
  }
}

#IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name     = "${var.project}-igw"
    Ambiente = var.env
  }
}

# Endereços IP elásticos (EIP) para cada NAT Gateway
resource "aws_eip" "nat" {
  count = 2
}


# NAT Gateway em cada subnet pública
# Cria 2 Endereços IP elásticos (EIP) para serem usados pelos NATs (um por AZ).
# Cria 2 NAT Gateways (um em cada subnet pública).
# Permite que instâncias em subnets privadas acessem a internet, mas SEM expor IP público.
resource "aws_nat_gateway" "nat" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name     = "${var.project}-nat-${element(var.azs, count.index)}"
    Ambiente = var.env
  }
}

# Route table Pública(e associação)
# Garante que qualquer recurso lançado numa subnet pública (EC2, ELB, NAT Gateway etc.) tenha acesso à internet.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name     = "${var.project}-public-rt"
    Ambiente = var.env
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table para subnets privadas (uma para cada AZ)
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name     = "${var.project}-private-rt-${element(var.azs, count.index)}"
    Ambiente = var.env
  }
}

resource "aws_route" "private_nat_access" {
  count                  = 2
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}



# IAM Role para o Cluster EKS
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
  tags = {
    Name = "${var.project}-eks-cluster-role"
    Ambiente = var.env
  }
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# IAM Role para o Node Group (EC2)
resource "aws_iam_role" "eks_nodegroup" {
  name = "${var.project}-eks-nodegroup-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json
  tags = {
    Name = "${var.project}-eks-nodegroup-role"
    Ambiente = var.env
  }
}

data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_nodegroup.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_nodegroup.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_nodegroup.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
