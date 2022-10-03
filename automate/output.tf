output "automate_public_dns" {
  value = aws_instance.automate.public_dns
}

output "automate_ssh" {
  value = "ssh ubuntu@${aws_instance.automate.public_dns}"
}
