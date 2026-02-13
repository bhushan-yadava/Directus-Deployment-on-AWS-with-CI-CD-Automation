output "public_ip" {
  value = aws_instance.directus_server.public_ip
}

output "instance_id" {
  value = aws_instance.directus_server.id
}

output "directus_url" {
  value = "http://${aws_instance.directus_server.public_ip}:8055"
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
