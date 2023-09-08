locals {
  identity_providers = {
    for k, v in var.federated_identity_providers : k => merge(
      v,
      lookup(local.identity_providers_defs, v.issuer, {})
    )
  }
  # settings takes preceds over var.federetadet_identity_providers
  identity_providers_defs = {
    # https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
    /*github = {
        attribute_mapping = {
          "google.subject"             = "assertion.sub"
          "attribute.sub"              = "assertion.sub"
          "attribute.actor"            = "assertion.actor"
          "attribute.repository"       = "assertion.repository"
          "attribute.repository_owner" = "assertion.repository_owner"
          "attribute.ref"              = "assertion.ref"
        }
        issuer_uri       = "https://token.actions.githubusercontent.com"
        principal_tpl    = "principal://iam.googleapis.com/%s/subject/repo:%s:ref:refs/heads/%s"
        principalset_tpl = "principalSet://iam.googleapis.com/%s/attribute.repository/%s"
        openid_configuration = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
      }*/
    # https://docs.gitlab.com/ee/ci/cloud_services/index.html#how-it-works
    gitlab = {
      attribute_mapping = {
        "google.subject"                  = "assertion.sub"
        "attribute.sub"                   = "assertion.sub"
        "attribute.environment"           = "assertion.environment"
        "attribute.environment_protected" = "assertion.environment_protected"
        "attribute.namespace_id"          = "assertion.namespace_id"
        "attribute.namespace_path"        = "assertion.namespace_path"
        "attribute.pipeline_id"           = "assertion.pipeline_id"
        "attribute.pipeline_source"       = "assertion.pipeline_source"
        "attribute.project_id"            = "assertion.project_id"
        "attribute.project_path"          = "assertion.project_path"
        "attribute.repository"            = "assertion.project_path"
        "attribute.ref"                   = "assertion.ref"
        "attribute.ref_protected"         = "assertion.ref_protected"
        "attribute.ref_type"              = "assertion.ref_type"
      }
      allowed_audiences    = ["https://gitlab.com"]
      issuer_uri           = "https://gitlab.com"
      openid_configuration = "https://gitlab.com/.well-known/openid-configuration"
      default_attribute_condition = tolist([
        variable = "gitlab:aud"
        value = ["sts.amazonaws.com"]
      ])
      _merged_attribute_condition = merge(default_attribute_condition, attribute_condition)
    }
  }

  default_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}