# Content Security Policy (CSP).
# Enforced in development and production.

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self

  policy.script_src :self,
                    "https://challenges.cloudflare.com"

  policy.style_src :self, "https://fonts.googleapis.com"

  policy.font_src :self,
                  "https://fonts.gstatic.com",
                  "https://db.onlinewebfonts.com"

  policy.img_src :self, "https://res.cloudinary.com", :data

  policy.connect_src :self,
                     "https://challenges.cloudflare.com"

  policy.frame_src "https://challenges.cloudflare.com"

  policy.object_src :none
  policy.base_uri :self
  policy.form_action :self
end

Rails.application.config.content_security_policy_report_only = false
