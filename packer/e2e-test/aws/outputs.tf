# Outputs file
output "myapp_url" {
  value = "http://${aws_eip.myapp.public_dns}:8080"
}

output "myapp_ip" {
  value = "http://${aws_eip.myapp.public_ip}:8080"
}

output "health_endpoint" {
  value = "http://${aws_eip.myapp.public_dns}:8080/healthz"
}