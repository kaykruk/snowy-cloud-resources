#Specifies the region for the infrastructure 
variable "aws_region" {
  description = "Region where the environment will be"
  type        = string
  default     = "us-west-1"
}


variable "image_id"{
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
  default = "ami-0e618811ec643488b"
}

variable "security_group"{
  default = ["sg-0cf693afcbe1d3407"]
}