# Create an application with a provider attached and policies applied

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}


resource "authentik_provider_saml" "this" {
  name               = "${var.app_name}-saml"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  acs_url            = "http://localhost"
}

# resource "authentik_policy_expression" "policy" {
#   name       = "policy"
#   expression = "return True"
# }

# resource "authentik_policy_binding" "app-access" {
#   target = authentik_application.name.uuid
#   policy = authentik_policy_expression.policy.id
#   order  = 0
# }

resource "random_uuid" "slug" {
}

resource "authentik_application" "name" {
  name = var.app_name
  slug = resource.random_uuid.slug.result

  protocol_provider = authentik_provider_saml.this
}
