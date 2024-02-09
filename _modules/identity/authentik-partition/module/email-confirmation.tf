
resource "authentik_stage_email" "confirmation-email" {
  name                     = "confirmation-email"
  from_address             = var.from_email
  activate_user_on_success = true
  subject                  = "Account Confirmation"
  template                 = "email/account_confirmation.html"
}

resource "authentik_flow" "enrollment" {
  name        = "enrollment"
  title       = "Enrollment"
  slug        = "account-enrollment"
  designation = "enrollment"
}


data "authentik_stage" "default-source-enrollment-prompt" {
  name = "default-source-enrollment-prompt"
}

resource "authentik_flow_stage_binding" "default-source-enrollment-prompt" {
  target = authentik_flow.enrollment.uuid
  stage  = data.authentik_stage.default-source-enrollment-prompt.id
  order  = 10
}

data "authentik_stage" "default-source-enrollment-write" {
  name = "default-source-enrollment-write"
}

resource "authentik_flow_stage_binding" "default-source-enrollment-write" {
  target = authentik_flow.enrollment.uuid
  stage  = data.authentik_stage.default-source-enrollment-write.id
  order  = 20
}

resource "authentik_flow_stage_binding" "confirmation-email" {
  target = authentik_flow.enrollment.uuid
  stage  = authentik_stage_email.confirmation-email.id
  order  = 30
}
