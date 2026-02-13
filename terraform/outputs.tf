# ----------------------------
# EC2 Public IP
# ----------------------------

output "public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.directus_server.public_ip
}

# ----------------------------
# EC2 Instance ID
# ----------------------------

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.directus_server.id
}

# ----------------------------
# Directus URL
# ----------------------------

output "directus_url" {
  description = "Directus application URL"
  value       = "http://${aws_instance.directus_server.public_ip}:8055"
}

# ----------------------------
# Private SSH Key (Sensitive)
# ----------------------------

output "private_key" {
  description = "Generated private SSH key"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}
