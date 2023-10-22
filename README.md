# terraform-aws-oidc-provider





#### Example:
```
module "aws_oidc" {
  source                = "github.com/coactdev/terraform-aws-oidc-provider"
  federated_identity_providers = {
    "gitlab" = {
      attribute_condition = tolist([
        {
          variable = "gitlab:sub"
          values = [
            "project_path:coact.dev/infrastructure:ref_type:branch:staging",
            "project_path:coact.dev/infrastructure:ref_type:branch:production"
          ]
        }
      ])
      tags       = { "stage" = "bootstrap" }
      issuer     = "gitlab"
      policy_arn = ""
      policy_jsons = data.aws_iam_policy_document.terraform_organisation_management_policy.json
    }
  }
}
```

---
1. https://docs.gitlab.com/ee/ci/yaml/index.html#id_tokens