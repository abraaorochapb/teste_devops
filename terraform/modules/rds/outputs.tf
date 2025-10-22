output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.mysql.id
}

output "rds_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.mysql.arn
}

output "rds_instance_address" {
  description = "RDS instance address"
  value       = aws_db_instance.mysql.address
}