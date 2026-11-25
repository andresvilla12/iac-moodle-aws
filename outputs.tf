output "public_ip" {
  description = "IP publica de la instancia EC2 de Moodle"
  value       = aws_instance.moodle_server.public_ip
}

output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.moodle_server.id
}