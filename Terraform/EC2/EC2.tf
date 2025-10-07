
# this is an example of hard coding values instead of variables(variables.tf)

#provider "aws" {
    # use profile to authenticate instead of keys in script
  #  profile = "demo"
  #  region = "us-east-1"

# }

#resource "aws_instance" "my_demo_instance" {
   # ami = "ami-08982f1c5bf93d976" # an amazon linux instance from the catalog
    #instance_type = "t2.micro"
    #tags = {
     # Name: "DemoInstance"
    #}
#}

# run "terraform plan"
# then run "terraform apply"

#### Below is the same but using a variables.tf file

provider "aws" {
    profile = "${var.profile}"
    region = "${var.region}"
}

resource "aws_instance" "demo_instance" {
    #ami = "{var.ami-id}"
    ami = "${lookup(var.amis, var.region)}" # this built in function will check map variable
    instance_type = "t2.micro"
    #key_name = "MYLINUXVM_key"
    vpc_security_group_ids = ["sg-054338a8b6bae4f63"]

tags = {
    Name = "DemoInstance"
 }
/*provisioner "file" {
  source = "script.sh"
  destination = "/tmp/script.sh"
}

provisioner "remote-exec"{
    inline = [
        "chmod +x /tmp/script.sh",
        "sudo /tmp/script.sh"
    ]
}
# The connection parameter lets the provisioners connect to the remote machines to run these commands and scripts
connection {
   host = "${aws_instance.demo_instance.public_ip}"
   user = "ec2-user"
   private_key = "${file("${var.private_key_path}")}"

 }
*/
}

# We can generate outputs as well to veiw after terraform build is complete

output "pub_ip" {
  value = "${aws_instance.demo_instance.public_ip}"
}
output "instance_arn" {
  value = "${aws_instance.demo_instance.arn}"
}

