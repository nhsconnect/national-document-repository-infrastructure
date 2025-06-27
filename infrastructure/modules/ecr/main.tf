resource "aws_ecr_repository" "ndr-ecr" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
  force_delete = var.is_force_destroy
  tags = {
    Name        = "${terraform.workspace}-${var.app_name}"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_ecr_lifecycle_policy" "ndr_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ndr-ecr.name
  policy     = <<EOF
  {
      "rules": [
          {
              "rulePriority": 1,
              "description": "Expire images older than 7 days",
              "selection": {
                  "tagStatus": "untagged",
                  "countType": "sinceImagePushed",
                  "countUnit": "days",
                  "countNumber": 7
              },
              "action": {
                  "type": "expire"
              }
          }
      ]
  }
  EOF
}

resource "aws_ecr_repository_policy" "ndr_ecr_repository_policy" {
  repository = aws_ecr_repository.ndr-ecr.name
  policy     = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.current_account_id}:root"
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}