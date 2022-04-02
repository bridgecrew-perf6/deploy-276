terraform {
	required_providers {
	  aws = {
		  source = "hashicorp/aws"
		  version = "~> 4.0.0"
	  }
	}

	backend "s3" {
		bucket = "capstoneterraform"
		key ="terraform.tfstate"
		region = "ap-northeast-2"
	}
}

// Configure Provider
provider "aws" {
	region = "ap-northeast-2"
}