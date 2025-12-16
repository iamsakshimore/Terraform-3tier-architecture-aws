#print app server ip
output "public_ip" {
 value = aws_instance.public-server.public_ip
}
#print db server ip
output "private_ip" {
  value = aws_instance.private-server.private_ip
}
output "private_ip1" {
  value = aws_instance.private-server1.private_ip
}