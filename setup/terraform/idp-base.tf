# Ensure we don't have name conflicts

resource "random_string" "install_id" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

locals {
  app         = "5min-idp-${random_string.install_id.result}"
  prefix      = "${local.app}-"
  enviornment = "development-${random_string.install_id.result}"
}

resource "humanitec_application" "demo" {
  id   = local.app
  name = local.app
}

resource "humanitec_environment" "demo" {
  app_id = humanitec_application.demo.id
  id     = local.enviornment
  name   = "A demo environment for 5min-idp"
  type   = "development"
}

# Configure k8s namespace naming

resource "humanitec_resource_definition" "k8s_namespace" {
  driver_type = "humanitec/echo"
  id          = "${local.prefix}k8s-namespace"
  name        = "${local.prefix}k8s-namespace"
  type        = "k8s-namespace"

  driver_inputs = {
    values_string = jsonencode({
      "namespace" = "$${context.app.id}-$${context.env.id}"
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_namespace" {
  resource_definition_id = humanitec_resource_definition.k8s_namespace.id
  app_id                 = humanitec_application.demo.id

  force_delete = true
}

# Configure DNS for localhost

resource "humanitec_resource_definition" "dns_localhost" {
  id          = "${local.prefix}dns-localhost"
  name        = "${local.prefix}dns-localhost"
  type        = "dns"
  driver_type = "humanitec/newapp-io-dns"

  driver_inputs = {
    values_string = jsonencode({
      "template" = "$${context.app.id}-{{ randAlphaNum 4 | lower}}"
    })
  }

  provision = {
    ingress = {
      match_dependents = false
      is_dependent     = false
    }
  }
}

resource "humanitec_resource_definition_criteria" "dns_localhost" {
  resource_definition_id = humanitec_resource_definition.dns_localhost.id
  app_id                 = humanitec_application.demo.id

  force_delete = true
}

# Provide postgres resource

module "postgres_basic" {
  source = "github.com/humanitec-architecture/resource-packs-in-cluster//humanitec-resource-defs/postgres/basic?ref=v2024-06-07"
  prefix = local.prefix
}

resource "humanitec_resource_definition_criteria" "postgres_basic" {
  resource_definition_id = module.postgres_basic.id
  class                  = "default"
  app_id                 = humanitec_application.demo.id

  force_delete = true
}
