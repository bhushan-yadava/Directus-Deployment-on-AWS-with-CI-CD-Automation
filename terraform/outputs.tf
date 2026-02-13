output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.directus_server.public_ip
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.directus_server.id
}

output "directus_url" {
  description = "Directus URL"
  value       = "http://${aws_instance.directus_server.public_ip}:8055"
}

output "private_key" {
  description = "Private SSH Key"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}
