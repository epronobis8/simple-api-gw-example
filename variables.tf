variable "aws_region" {
  type    = string
  default = "us-east-1"
  #prompts user for the region
}

variable "dynamodb-name" {
  type    = string
  default = "product-inventory3"
  #If you change the name of the dynamodb table it will need to be updated in the lambda_function.py file (line 9)
}

variable "envTag" {
  type    = string
  default = "test"
}

variable "api-name" {
  type    = string
  default = "rest-api-product-inventory-app3"
}
