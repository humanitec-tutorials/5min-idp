variable "humanitec_org" {
  description = "The ID of the organization"
  default     = "humanitec"
  type        = string
}

variable "kubeconfig" {
  description = "Kubeconfig used by the Humanitec Agent / terraform"
  type        = string
  default     = "/state/kube/config-internal.yaml"
}

variable "operator_ns" {
  description = "Humanitec Operator Namespace"
  type = string
  default = "humanitec-operator-system"
}
