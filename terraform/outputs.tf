output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.employee_attendance.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.employee_attendance.public_ip
}

output "app_url" {
  description = "Employee Attendance application URL"
  value       = "http://${aws_instance.employee_attendance.public_ip}:5000"
}