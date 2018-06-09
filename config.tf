// access to aws API, create new user with EC2 permissions here `https://console.aws.amazon.com/iam/home?#/users`
// and put user's credentials to the `terraform.tfvars` file in the project directory
// (you have to create this file first).
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

// default region
variable "AWS_DEFAULT_REGION" { default = "us-east-1" }

// ssh key pair to manage and install software to EC2 instances.
// create key pair here `https://us-east-2.console.aws.amazon.com/ec2/v2/home?#KeyPairs:`,
// copy it's private *.pem key to project directory. Add to `terraform.tfvars` KEY_PAIR_NAME
// and PRIVATE_KEY_PATH
variable "KEY_PAIR_NAME" {}
variable "PRIVATE_KEY_PATH" {}

// how many proxy servers to create
variable "AWS_INSTANCES_COUNT"    { default = 1 }

variable "AWS_INSTANCE_TYPE"      { default = "t2.micro" }
variable "AWS_INSTANCE_AMI"       { default = "ami-6a003c0f" }
variable "AWS_INSTANCE_USER_NAME" { default = "ubuntu" }

variable "PROXY_PORT" { default = 46642 }
variable "PROXY_TYPE" { default = "socks" }
