output "private_ip_address" {
  value = aws_instance.monitoring-test.private_ip
}

output "public_ip_address" {
  value = aws_instance.monitoring-test.public_ip
}
