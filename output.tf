output "ip_address" {
  description = "IP address of our new instance"
  value       = aws_instance.my_tf_instance.public_ip
}