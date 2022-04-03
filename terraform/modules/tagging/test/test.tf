module "tagging" {
  source = "../"
  name        = "Test-Name"
  project     = "Test-Project"
  environment = "Test-Environment"
  owner       = "Test-Owner"
  compliance  = "Test-Compliance"
}

output "tags" {
  value = module.tagging.tags
}
