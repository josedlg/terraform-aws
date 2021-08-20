terraform{
    backend "s3" {
        bucket = "pipeline-nineone"
        encrypt = true
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
}

