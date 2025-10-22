data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = var.db_secret_name
}