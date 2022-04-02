resource "aws_security_group" "rds" {
	name = "rds"
	vpc_id = aws_default_vpc.default.id

	ingress {
		description = "Ingress from VPC"
		from_port = "3306"
		to_port = "3306"
		protocol = "tcp"
		cidr_blocks = ["172.31.0.0/16"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}
}

resource "aws_db_subnet_group" "rds" {
	name = "rds"
	subnet_ids = [aws_subnet.private.id, aws_subnet.public.id, aws_subnet.public2.id]
}

resource "aws_db_instance" "default" {
	allocated_storage = 10
	engine = "mysql"
	engine_version = "8.0.27"
	instance_class = "db.t2.micro"
	//db_name = "TBD"
	//username = "TBD"
	//password = "TBD"
	skip_final_snapshot = true
	parameter_group_name = "default.mysql8.0"

	vpc_security_group_ids = [aws_security_group.rds.id]
}