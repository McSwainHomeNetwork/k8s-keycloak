variable "k8s_host" {
  type        = string
  description = "Address of the k8s host."
  sensitive   = true
}

variable "k8s_client_key" {
  type        = string
  default     = ""
  description = "Private key by which to auth with the k8s host."
  sensitive   = true
}

variable "k8s_cluster_ca_cert" {
  type        = string
  default     = ""
  description = "CA cert of the k8s host."
  sensitive   = true
}

variable "k8s_client_certificate" {
  type        = string
  default     = ""
  description = "CA cert of the k8s host."
  sensitive   = true
}

variable "keycloak_db_password" {
  type        = string
  description = "Keycloak database password"
  sensitive   = true
}

variable "keycloak_ui_password" {
  type        = string
  description = "Keycloak UI password"
  sensitive   = true
}

variable "keycloak_db_address" {
  type        = string
  description = "Keycloak database address"
  sensitive   = true
}
