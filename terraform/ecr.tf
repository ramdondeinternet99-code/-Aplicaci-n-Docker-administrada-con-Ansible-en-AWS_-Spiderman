resource "aws_ecr_repository" "app" {
  #checkov:skip=CKV_AWS_51:Se usa el tag mutable 'latest' ademas del tag inmutable por SHA
  #checkov:skip=CKV_AWS_136:Cifrado AES256 administrado por AWS; KMS propio genera costo adicional
  name                 = var.project
  image_tag_mutability = "MUTABLE"
  force_delete         = true # permite terraform destroy aunque haya imagenes

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Control de costos: solo se conservan las ultimas 5 imagenes
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Conservar solo las ultimas 5 imagenes"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = { type = "expire" }
    }]
  })
}
