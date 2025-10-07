

provider "aws" {
   profile = "demo"
   region = "us-east-1" 
}

resource "aws_vpc" "demo-vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
   Name = "public-subnet"
  }

}

resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
   Name = "private-subnet"
  }

}

/*
resource "aws_db_subnet_group" "mysql-subnet-group" {
    name = "mysql-subnet-group"
    subnet_ids = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}"]
}
*/

 resource "aws_internet_gateway" "vpc-igw" {
   vpc_id = "${aws_vpc.demo-vpc.id}"

   tags = {
   Name = "MyVPC-IGW"
  }
 }

 resource "aws_route_table" "public-rtb" {
   vpc_id = "${aws_vpc.demo-vpc.id}"

   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc-igw.id}"
   }
   tags = {
     Name = "Public Route Table"
   }
 }

 resource "aws_route_table_association" "public-route" {
   route_table_id = "${aws_route_table.public-rtb.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
 }
 resource "aws_route_table_association" "private-route" {
    route_table_id = "${aws_route_table.demo-rtb.id}"
    subnet_id = "${aws_subnet.private-subnet.id}"
 }

 resource "aws_network_acl" "public-nacl" {
   vpc_id = "${aws_vpc.demo-vpc.id}"
   subnet_ids = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}"]

   ingress {
     rule_no = "100"
     protocol = "tcp"
     from_port = "80"
     to_port = "80"
     action = "allow"
     cidr_block = "0.0.0.0/0"
   }

   ingress {
     rule_no = "200"
     protocol = "tcp"
     from_port = "1024"
     to_port = "65535"
     action = "allow"
     cidr_block = "0.0.0.0/0"
   }

   ingress {
     rule_no = "300"
     protocol = "tcp"
     from_port = "22"
     to_port =  "22"
     action = "allow"
     cidr_block = "0.0.0.0/0"
   }

   egress  {
    rule_no = "100"
    protocol = "tcp"
    from_port = "80"
    to_port = "80"
    action = "allow"
    cidr_block = "0.0.0.0/0"
   }

   egress  {
     rule_no = "200"
     protocol = "tcp"
     from_port = "1024"
     to_port = "65535"
     action = "allow"
     cidr_block = "0.0.0.0/0"
   }

   egress {
    rule_no = "300"
     protocol = "tcp"
     from_port = "22"
     to_port =  "22"
     action = "allow"
     cidr_block = "0.0.0.0/0"
   }
 }

resource "aws_security_group" "webserver-sg" {
  name = "WebDMZ"
  description = "Security group for web server"
  vpc_id = "${aws_vpc.demo-vpc.id}"

  ingress {
    from_port = "80"
    to_port = "80"
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }
  ingress {
    from_port = "22"
    to_port =  "22"
    cidr_blocks = ["104.15.4.198/32"]
    protocol = "tcp"
  }

  
}

resource "aws_security_group" "lb-sg" {
   name = "LoadBalancerSG"
   description = "Security group for ALB"
   vpc_id = "${aws_vpc.demo-vpc.id}"


   ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
}

/*resource "aws_security_group" "db-sg" {
   name = "MysqlSG"
   description = "Security group for mysql"
   vpc_id = "${aws_vpc.demo-vpc.id}"

  ingress {
    from_port = "3306"
    to_port = "3306"
    cidr_blocks =  ["0.0.0.0/0"]
    protocol = "tcp"
  }
}
*/
resource "aws_instance" "web-server1" {
  ami = "ami-08982f1c5bf93d976"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.webserver-sg.id}"]
  key_name = "MYLINUXVM_key"
  user_data = "${file("script.sh")}"
  subnet_id = "${aws_subnet.private-subnet.id}"
}

resource "aws_instance" "web-server2" {
  ami = "ami-08982f1c5bf93d976"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.webserver-sg.id}"]
  key_name = "MYLINUXVM_key"
  user_data = "${file("script2.sh")}"
  subnet_id = "${aws_subnet.private-subnet}"
}

resource "aws_lb" "web-lb" {
  name = "web-lb"
  internal = false
  load_balancer_type = "application"
  subnets = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}"]
  security_groups = ["${aws_security_group.lb-sg.id}"]
}

resource "aws_lb_target_group" "web-tg" {
  name = "web-tg"
  port = "80"
  protocol = "HTTP"
  vpc_id = "${aws_vpc.demo-vpc.id}"
  
}

resource "aws_lb_listener" "web-lb-listener" {
 default_action {
     type = "forward"
     target_group_arn = "${aws_lb_target_group.web-tg.arn}"
   }
   load_balancer_arn = "${aws_lb.web-lb.arn}"
   port = "80"
   protocol = "HTTP"
}

resource "aws_lb_target_group_attachment" "web-tg-attachment" {
  target_id = "${aws_instance.web-server1.id}"
  target_group_arn = "${aws_lb_target_group.web-tg.arn}"
  port = "80"
}

resource "aws_lb_target_group_attachment" "web-tg-attachment2" {
  target_id = "${aws_instance.web-server2.id}"
  target_group_arn = "${aws_lb_target_group.web-tg.arn}"
  port = "80"
}

/*
resource "aws_db_instance" "mysql-db" {
  allocated_storage = "20"
  storage_type = "gp2"
  instance_class = "db.t4g.micro"
  engine_version = "8.0.42"
  engine = "mysql"
  username = "mysql_user"
  password = "mysql-passwod"
  skip_final_snapshot = true
  db_subnet_group_name = "${aws_db_subnet_group.mysql-subnet-group.id}"
  vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]
}

*/