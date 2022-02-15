terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

data "terraform_remote_state" "k8s_user_pki" {
  backend = "remote"

  count = (length(var.k8s_client_certificate) > 0 && length(var.k8s_client_key) > 0 && length(var.k8s_cluster_ca_cert) > 0) ? 0 : 1

  config = {
    organization = "McSwainHomeNetwork"
    workspaces = {
      name = "k8s-user-pki"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    client_certificate     = length(var.k8s_client_certificate) > 0 ? var.k8s_client_certificate : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_cert_pem
    client_key             = length(var.k8s_client_key) > 0 ? var.k8s_client_key : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_key_pem
    cluster_ca_certificate = length(var.k8s_cluster_ca_cert) > 0 ? var.k8s_cluster_ca_cert : data.terraform_remote_state.k8s_user_pki[0].outputs.ca_cert_pem
  }
}

provider "kubernetes" {
  host                   = var.k8s_host
  client_certificate     = length(var.k8s_client_certificate) > 0 ? var.k8s_client_certificate : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_cert_pem
  client_key             = length(var.k8s_client_key) > 0 ? var.k8s_client_key : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_key_pem
  cluster_ca_certificate = length(var.k8s_cluster_ca_cert) > 0 ? var.k8s_cluster_ca_cert : data.terraform_remote_state.k8s_user_pki[0].outputs.ca_cert_pem
}

resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "https://usa-reddragon.github.io/helm-charts"
  chart      = "app"
  version    = "0.1.7"
  namespace = "keycloak"
  create_namespace = true

  set {
    name  = "image.repository"
    value = "quay.io/keycloak/keycloak"
    type  = "string"
  }

  set {
    name  = "image.tag"
    value = "17.0.0-legacy"
    type  = "string"
  }

  set {
    name  = "ingress.hosts[0].host"
    value = "keycloak.mcswain.dev"
    type  = "string"
  }

  set {
    name  = "ingress.hosts[0].paths[0].port"
    value = "8080"
  }

  set {
    name  = "ingress.hosts[0].paths[0].path"
    value = "/"
    type  = "string"
  }

  set {
    name  = "ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
    type  = "string"
  }

  set {
    name  = "ingress.tls[0].secretName"
    value = "keycloak-mcswain-dev-tls"
    type  = "string"
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "keycloak.mcswain.dev"
    type  = "string"
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
    type  = "string"
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/tls-acme"
    value = "true"
    type  = "string"
  }

  set {
    name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "cloudflare"
    type  = "string"
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/ssl-redirect"
    value = "true"
    type  = "string"
  }

  set {
    name  = "probes.liveness.httpGet.path"
    value = "/auth/realms/master"
    type  = "string"
  }

  set {
    name  = "probes.liveness.httpGet.port"
    value = "http"
    type  = "string"
  }

  set {
    name  = "probes.readiness.httpGet.path"
    value = "/auth/realms/master"
    type  = "string"
  }

  set {
    name  = "probes.readiness.httpGet.port"
    value = "http"
    type  = "string"
  }

  set {
    name  = "service.ports[0].name"
    value = "http"
    type  = "string"
  }

  set {
    name  = "service.ports[0].port"
    value = "8080"
  }

  set {
    name  = "env[0].name"
    value = "KEYCLOAK_USER"
    type  = "string"
  }

  set {
    name  = "env[0].value"
    value = "admin"
    type  = "string"
  }

  set {
    name  = "env[1].name"
    value = "PROXY_ADDRESS_FORWARDING"
    type  = "string"
  }

  set {
    name  = "env[1].value"
    value = "true"
    type  = "string"
  }

  set {
    name  = "env[2].name"
    value = "DB_VENDOR"
    type  = "string"
  }

  set {
    name  = "env[2].value"
    value = "postgres"
    type  = "string"
  }

  set {
    name  = "env[3].name"
    value = "DB_USER"
    type  = "string"
  }

  set {
    name  = "env[3].value"
    value = "keycloak"
    type  = "string"
  }

  set {
    name  = "env[4].name"
    value = "DB_ADDR"
    type  = "string"
  }

  set {
    name  = "env[4].valueFrom.secretKeyRef.name"
    value = "keycloak-creds"
    type  = "string"
  }

  set {
    name  = "env[4].valueFrom.secretKeyRef.key"
    value = "db-address"
    type  = "string"
  }

  set {
    name  = "env[5].name"
    value = "KEYCLOAK_PASSWORD"
    type  = "string"
  }

  set {
    name  = "env[5].valueFrom.secretKeyRef.name"
    value = "keycloak-creds"
    type  = "string"
  }

  set {
    name  = "env[5].valueFrom.secretKeyRef.key"
    value = "ui-password"
    type  = "string"
  }

  set {
    name  = "env[6].name"
    value = "DB_PASSWORD"
    type  = "string"
  }

  set {
    name  = "env[6].valueFrom.secretKeyRef.name"
    value = "keycloak-creds"
    type  = "string"
  }

  set {
    name  = "env[6].valueFrom.secretKeyRef.key"
    value = "db-password"
    type  = "string"
  }

  set {
    name  = "secrets[0].name"
    value = "keycloak-creds"
    type  = "string"
  }

  set {
    name  = "secrets[0].data.db-password"
    value = var.keycloak_db_password
    type  = "string"
  }

  set {
    name  = "secrets[0].data.ui-password"
    value = var.keycloak_ui_password
    type  = "string"
  }

  set {
    name  = "secrets[0].data.db-address"
    value = var.keycloak_db_address
    type  = "string"
  }

}
