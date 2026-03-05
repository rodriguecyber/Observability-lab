output "instance_id" {
  value = aws_instance.observability.id
}

output "instance_public_ip" {
  value = aws_instance.observability.public_ip
}

output "security_group_id" {
  value = aws_security_group.observability.id
}
