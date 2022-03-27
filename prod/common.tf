// Default Resource : it is not destroyed
resource "aws_default_vpc" "default" {

}
resource "aws_subnet" "private" {
  vpc_id = aws_default_vpc.default.id
  cidr_block = "172.31.112.0/24"
}

resource "aws_subnet" "public1" {
  vpc_id = aws_default_vpc.default.id
  cidr_block = "172.31.212.0/24"
}

resource "aws_subnet" "public2" {
  vpc_id = aws_default_vpc.default.id
  cidr_block = "172.31.213.0/24"
}