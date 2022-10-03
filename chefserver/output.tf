output "cs_public_dns" {
  value = aws_instance.chefserver.public_dns
}
output "cs_ssh" {
  value = "ssh ubuntu@${aws_instance.chefserver.public_dns}"
}
