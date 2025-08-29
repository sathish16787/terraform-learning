terraform {
backend "s3" {
bucket = "random-tf-test"
key = "workspaces-practical/terraform.tfstate"
region = "ap-southeast-1"
dynamodb_table = "random-tf-state-locks"
encrypt = true
}
}