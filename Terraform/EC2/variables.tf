variable "profile" {
    default = "demo"
}

variable "region" {
    default = "us-east-1"
}

#variable "ami-id" {
    # this is an ubuntu image
   # default = "ami-0360c520857e3138f"
#}

# intead of using 'ami-id' we can also map amis in different regions 
# since the default is us-east-1, it will pick the one with us-east-1
variable "amis" {
    type = map(string)
    default = {
        us-east-1 = "ami-08982f1c5bf93d976" # amazon linux image in east1
        us-east-2 = "ami-0cfde0ea8edd312d4" # ubuntu image in east2
    }
}

variable "private_key_path" {
    default = "MYLINUXVM_key.pem"
}
