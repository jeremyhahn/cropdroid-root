
resource "aws_ecr_repository" "service" {
  name = local.final_project_name

  image_scanning_configuration {
    scan_on_push = var.image_scanning
  }
}

resource "aws_ecr_lifecycle_policy" "service" {
  repository = aws_ecr_repository.service.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      action       = {
        type = "expire"
      }
      selection     = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
    }]
  })
}

resource "aws_ecr_repository_policy" "service" {
  repository = aws_ecr_repository.service.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
      {
          "Sid": "AllowAmazonServices",
          "Effect": "Allow",
          "Principal": {
            "AWS": ${jsonencode(var.ecr_allowed_principals)}
          },
          "Action": [
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:CompleteLayerUpload",
            "ecr:GetDownloadUrlForLayer",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
          ]
      }
    ]
}
EOF
}
