data "aws_region" "current" {}

resource "aws_cognito_user_pool" "main" {
  name = "${lower(var.project)}-${lower(var.environment)}-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = true
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = {
    Name = "${lower(var.project)}-${lower(var.environment)}-user-pool"
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  user_pool_id = aws_cognito_user_pool.main.id
  domain       = "${lower(var.project)}-${lower(var.environment)}-auth"
}

resource "aws_cognito_user_pool_client" "main" {
  name = "${lower(var.project)}-${lower(var.environment)}-client"

  user_pool_id = aws_cognito_user_pool.main.id

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
  generate_secret               = false
  refresh_token_validity        = 30

  callback_urls                        = [var.redirect_url]
  logout_urls                          = [var.redirect_url]
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid"]
  allowed_oauth_flows_user_pool_client = true
  supported_identity_providers         = ["COGNITO"]

  enable_token_revocation = true
  access_token_validity   = 60
  id_token_validity       = 60
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}
