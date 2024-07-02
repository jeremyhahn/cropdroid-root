output "codebuild_service_role" {
    value = aws_iam_role.codebuild.arn
}

output "container_build_role" {
    value = aws_iam_role.container_build.arn
}

output "repository_url" {
    value = aws_ecr_repository.service.repository_url
}
