resource "aws_vpc" "main" {
  #checkov:skip=CKV2_AWS_11:Flow logs omitidos en el taller para limitar costos
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project}-vpc" }
}

# Bloquea el SG por defecto (sin reglas)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-default-sg-locked" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-igw" }
}

resource "aws_subnet" "public" {
  #checkov:skip=CKV_AWS_130:La subred es publica a proposito; la IP publica se asigna con una Elastic IP
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.project}-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.project}-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# El puerto 22 NO tiene regla permanente abierta al mundo: solo admin_cidr.
# (El pipeline abre temporalmente la IP del runner y la revoca al terminar.)
resource "aws_security_group" "app" {
  #checkov:skip=CKV_AWS_260:El puerto 80 debe ser publico porque es la aplicacion web
  name        = "${var.project}-sg"
  description = "Acceso HTTP publico y SSH restringido"
  vpc_id      = aws_vpc.main.id

  # El puerto 80 es publico porque es la aplicacion web
  #trivy:ignore:AVD-AWS-0107
  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH solo desde IP autorizada"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Solo HTTPS de salida (dnf, ECR, PyPI, Docker Hub)
  #trivy:ignore:AVD-AWS-0104
  egress {
    description = "HTTPS de salida"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-sg" }
}
