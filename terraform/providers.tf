provider "aws" {
  version = "~> 1.60.0"
}

provider "aws" {
  version = "~> 1.60.0"
  alias   = "us-east-1"
  region  = "us-east-1"
}

provider "template" {
  version = "~> 1.0.0"
}
