resource "aws_iam_instance_profile" "bastion" {
  count = var.create_bastion_host ? 1 : 0
  name  = "bastion-${var.env}"
  role  = aws_iam_role.bastion[0].name
}

resource "aws_iam_role" "bastion" {
  count = var.create_bastion_host ? 1 : 0
  name  = "bastion-${var.env}"
  path  = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
              "Service": "ec2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

# resource "aws_iam_policy" "bastion" {
#   name        = "bastion-ecr"
#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "ecr:GetAuthorizationToken",
#           "ecr:DescribeImages",
#           "ecr:DescribeRepositories"
#         ],
#         "Resource": "*"
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:BatchGetImage",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:GetDownloadUrlForLayer"
#         ],
#         "Resource": [
#           "arn:aws:ecr:${var.region}:${data.terraform_remote_state.shared_bootstrap.outputs.shared_account_id}:repository/docker-base-master-shared"
#         ]
#       }
#     ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "bastion" {
#   count      = var.create_bastion_host ? 1 : 0
#   role       = aws_iam_role.bastion[0].name
#   policy_arn = aws_iam_policy.bastion.arn
# }
