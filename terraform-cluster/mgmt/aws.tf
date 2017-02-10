provider "aws" {
    shared_credentials_file = "/home/${USER}/.aws/creds"
    region = "${var.region}"
}
