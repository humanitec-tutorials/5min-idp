variable "humanitec_org" {
  description = "The ID of the organization"
  default     = "humanitec"
  type        = string
}

variable "agent_id" {
  description = "The ID of the agent"
  default     = "5min-idp"
  type        = string
}

variable "kubeconfig" {
  description = "Kubeconfig used by terraform"
  type        = string
  default     = "../../kube/config.yaml"
}

variable "agent_kubeconfig" {
  description = "Kubeconfig used by the Humanitec Agent"
  type        = string
  default     = "../../kube/config-internal.yaml"
}

resource "tls_private_key" "agent_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
