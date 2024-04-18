# Configure k8s namespace naming

resource "humanitec_resource_definition" "k8s_namespace" {
  driver_type = "humanitec/echo"
  id          = "default-namespace"
  name        = "default-namespace"
  type        = "k8s-namespace"

  driver_inputs = {
    values_string = jsonencode({
      "namespace" = "$${context.app.id}-$${context.env.id}"
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_namespace" {
  resource_definition_id = humanitec_resource_definition.k8s_namespace.id
}

# Configure DNS for localhost

resource "humanitec_resource_definition" "localhost_dns" {
  id          = "localhost-dns"
  name        = "localhost-dns"
  type        = "dns"
  driver_type = "humanitec/dns-wildcard"

  driver_inputs = {
    values_string = jsonencode({
      "domain"   = "localhost"
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

resource "humanitec_resource_definition_criteria" "localhost_dns" {
  resource_definition_id = humanitec_resource_definition.localhost_dns.id
}

# Provide postgres resource

module "postgres_basic" {
  # Not pinned as we don't have a release yet
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/humanitec-architecture/resource-packs-in-cluster//humanitec-resource-defs/postgres/basic"
  prefix = "5min-idp-"
}

resource "humanitec_resource_definition_criteria" "postgres_basic" {
  resource_definition_id = module.postgres_basic.id
  class                  = "default"
  force_delete           = true
}
