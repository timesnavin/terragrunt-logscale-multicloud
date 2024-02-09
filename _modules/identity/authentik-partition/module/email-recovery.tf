resource "authentik_policy_password" "strong-password-policy" {
  name             = "partition"
  length_min       = 12
  amount_digits    = 0
  amount_lowercase = 0
  amount_symbols   = 0
  amount_uppercase = 0
  check_zxcvbn     = true
  error_message    = "Password must be hard to guess"
}

resource "authentik_stage_identification" "recovery-authentication-identification" {
  name        = "recovery-authentication-identification"
  user_fields = ["username", "email"]
  //sources        = [authentik_source_oauth.name.uuid]
  #3a0bb404-e22b-4641-b70c-ac1c923609b2
  //password_stage = authentik_stage_password.name.id
  case_insensitive_matching = true
}

# Create email stage for email verification, uses global settings by default

resource "authentik_stage_email" "recovery-email" {
  name                     = "recovery-email"
  from_address             = var.from_email
  activate_user_on_success = true
  subject                  = "Account Recovery"
}


resource "authentik_flow" "recovery" {
  name        = "recovery"
  title       = "Account Recovery"
  slug        = "account-recovery"
  designation = "recovery"
}

resource "authentik_flow_stage_binding" "recovery-authentication-identification" {
  target = authentik_flow.recovery.uuid
  stage  = authentik_stage_identification.recovery-authentication-identification.id
  order  = 0
}

resource "authentik_flow_stage_binding" "recovery-email" {
  target = authentik_flow.recovery.uuid
  stage  = authentik_stage_email.recovery-email.id
  order  = 10
}

data "authentik_stage" "default-password-change-prompt" {
  name = "default-password-change-prompt"
}

resource "authentik_flow_stage_binding" "default-password-change-prompt" {
  target = authentik_flow.recovery.uuid
  stage  = data.authentik_stage.default-password-change-prompt.id
  order  = 20
}


data "authentik_stage" "default-password-change-write" {
  name = "default-password-change-write"
}

resource "authentik_flow_stage_binding" "default-password-change-write" {
  target = authentik_flow.recovery.uuid
  stage  = data.authentik_stage.default-password-change-write.id
  order  = 30
}
