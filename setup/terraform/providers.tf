terraform {
  backend "local" {
    path = "/state/terraform/terraform.tfstate"
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    humanitec = {
      source  = "humanitec/humanitec"
      version = "~> 1.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "humanitec" {
  org_id = var.humanitec_org
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig
}
