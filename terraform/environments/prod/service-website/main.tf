
// Create s3 static website bucket, cloudfront distribution,
// route 53 entries, and SSL certificate
module "service_dashboard" {
  source                    = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-s3-static-website?ref=v0.0.1a"
  env                       = var.env
  profile                   = var.profile
  region                    = var.region
  bucket_name               = var.website_bucket
  external_dns_name         = local.external_dns_name
  external_zone_id          = local.external_dns_zone_id
  subject_alternative_names = local.subject_alternative_names
  enable_cloudfront         = true
  pipeline_role_arn         = module.pipeline_service_dashboard.codebuild_service_role
  alert_topic_arn           = local.sns_topic_arn
  enable_health_checks      = var.enable_health_checks
  enable_waf                = var.enable_waf
  tags                      = local.tags
}

// Create the deployment pipeline that redeploys the website to the
// above static website bucket when the source artifact changes.
module "pipeline_service_dashboard" {
  source               = "git::https://git-codecommit.us-east-1.amazonaws.com/v1/repos/tf-module-pipeline-deploy-s3-static-website?ref=v0.0.1a"
  env                  = var.env
  region               = var.region
  artifact_bucket      = data.terraform_remote_state.shared_pipeline_website.outputs.artifact_bucket
  artifact_object_key  = "service-website.zip"
  website_name         = "cropdroid"
  website_bucket       = var.website_bucket
  buildspec_template   = file("files/buildspec.yml")
  environment_variables = [{
    name = "WEBSITE_BUCKET"
    value = var.website_bucket
  }]
  tags = local.tags
}
