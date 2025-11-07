resource "aws_route53_zone" "public" {
  name = var.zone_name

  tags = {
    Name = "The public hosted zone for GP registrations dashboard."
  }
}
