provider "aws" {
  region  = var.region
  profile = var.aws_profile
  default_tags {
    tags = {
      Name  = "jenkins-server-deployment-using-terraform"
      Owner = "learnwithaniket.com"
    }
  }
}