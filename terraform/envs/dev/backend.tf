terraform {
  backend "s3" {
    bucket          = "jobhunt-terraform-state-989126024881"
    key             = "envs/dev/terraform.tfstate"
    region          = "us-east-1"
    dynamodb_table  = "jobhunt-terraform-lock"
    encrypt         = true
    profile         = "launchpad"
  }
}
