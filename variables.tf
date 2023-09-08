variable "federated_identity_providers" {
  description = "Workload Identity Federation pools. The `cicd_repositories` variable references keys here."
  type = map(object({
    attribute_condition = list(object({
      variable = string
      values   = list(string)
    }))
    issuer       = string
    issuer_uri   = string
    tags         = map(string)
    policy_arn   = list(string)
    policy_jsons = list(string)
  }))

  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for jsn in var.federated_identity_providers.policy_jsons : can(jsondecode(jsn))
    ])
    error_message = "All supplied policies must be valid json."
  }
}


variable "policy_arns" {
  type        = list(string)
  description = "List of policy ARNs for the assumable role. Defaults to [\"arn:aws:iam::aws:policy/ReadOnlyAccess\"]"
  default     = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}

variable "policy_jsons" {
  type        = list(string)
  description = "List of policy jsons for the assumable role. Defaults to []"
  default     = []
  validation {
    condition = alltrue([
      for jsn in var.policy_jsons : can(jsondecode(jsn))
    ])
    error_message = "All supplied policies must be valid json."
  }
}