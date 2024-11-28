terraform {
    backend "s3" {
        bucket         = "skibidimaxxingbucket"
        key            = "terraform.tfstate"
        dynamodb_table = "mod-remote-state-lock"
        region         =  "us-west-2" 
        encrypt        = true
    }
}
