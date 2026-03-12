variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "allowed_oauth_flows" {
  type        = list(string)
  description = "Allowed OAuth flows"
}

variable "callback_urls" {
  type        = list(string)
  description = "OAuth callback URLs"
}

variable "redirect_url" {
  description = "URL to redirect users after login"
  type        = string
}

variable "temporary_password_validity_days" {
  description = "Number of days a temporary password is valid"
  type        = number
}

variable "final_access_url" {
  description = "URL para acceso después de cambiar contraseña"
  type        = string
}