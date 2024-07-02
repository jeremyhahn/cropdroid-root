
resource "aws_iam_role" "cwe" {
  name                  = "cwe-${local.final_project_name}"
  assume_role_policy    = data.aws_iam_policy_document.trustrole.json
  force_detach_policies = true
}

data "aws_iam_policy_document" "trustrole" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_policy" "cwe" {
  name   = "cwe-${local.final_project_name}"
  path   = "/service-role/"
  policy = data.aws_iam_policy_document.cwe.json
}

data "aws_iam_policy_document" "cwe" {

  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    resources = ["arn:aws:codepipeline:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:${local.final_project_name}"]
  }
}

resource "aws_iam_role_policy_attachment" "cwe" {
  role       = aws_iam_role.cwe.id
  policy_arn = join("", aws_iam_policy.cwe.*.arn)
}
