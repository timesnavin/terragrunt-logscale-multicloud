# Create an application with a provider attached and policies applied
locals {
  fqdn      = "${var.host_prefix}-${var.tenant}.${var.domain_name}"
  namespace = "${var.host_prefix}-${var.tenant}"
}


data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_certificate_key_pair" "generated" {
  name              = "authentik Self-signed Certificate"
  fetch_certificate = true
  fetch_key         = false

}

data "authentik_property_mapping_saml" "this" {
  managed_list = [
    "goauthentik.io/providers/saml/email",
    "goauthentik.io/providers/saml/groups",
    "goauthentik.io/providers/saml/name",
    "goauthentik.io/providers/saml/uid",
    "goauthentik.io/providers/saml/upn"
  ]
}

data "authentik_property_mapping_saml" "upn" {
  managed = "goauthentik.io/providers/saml/upn"
}

resource "authentik_provider_saml" "this" {
  name               = "${local.namespace}-saml"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  acs_url            = "https://${local.fqdn}/api/v1/saml/acs"
  sp_binding         = "post"
  signing_kp         = data.authentik_certificate_key_pair.generated.id

  audience          = "https://${local.fqdn}/api/v1/saml/metadata"
  property_mappings = data.authentik_property_mapping_saml.this.ids
  name_id_mapping   = data.authentik_property_mapping_saml.upn.id
  # property_mappings = [
  #   "authentik default SAML Mapping: Email",
  #   "authentik default SAML Mapping: Groups",
  #   "authentik default SAML Mapping: Name"
  # ]
}

data "authentik_provider_saml_metadata" "provider" {
  provider_id = authentik_provider_saml.this.id
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

  protocol_provider = authentik_provider_saml.this.id
}
