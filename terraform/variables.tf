variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "taller2-ansible-docker"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "team" {
  type    = string
  default = "SPIDERMAN"
}

variable "admin_cidr" {
  type        = string
  description = "IP autorizada para administración SSH, ej: 190.10.20.30/32"

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr debe ser un CIDR válido y NUNCA 0.0.0.0/0."
  }
}

variable "ssh_public_key" {
  type        = string
  description = "Contenido de la llave pública SSH (ssh-ed25519 AAAA...)"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Limitado para controlar costos"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t2.micro"], var.instance_type)
    error_message = "Solo se permiten t3.micro, t3.small o t2.micro."
  }
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "budget_email" {
  type        = string
  default     = ""
  description = "Correo para alertas de presupuesto (vacío = no crea presupuesto)"
}

variable "budget_limit_usd" {
  type    = number
  default = 10
}
