resource "aws_security_group" "bastion" {
	name = "bastion"
	vpc_id = aws_default_vpc.default.id

	ingress {
		description = "Ingress from Host"
		from_port = 0
		to_port = "22"
		protocol = "tcp"
		//cidr_blocks = ["TBD/32"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}
}

data "aws_ami" "ubuntu" {
	most_recent = true
	filter {
	  	name = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"] 
	}
	owners = ["099720109477"] // Canonical
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.4.0"

  name = "bastion"
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  //key_name = "TBD"
  monitoring = true
  subnet_id = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  associate_public_ip_address = true
}