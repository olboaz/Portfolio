# Content Security Policy (CSP).
# Development: enforced.
# Production: Report-Only until production validation is complete.

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self

  policy.script_src :self,
                    "https://challenges.cloudflare.com"

  policy.style_src :self,
                   "https://fonts.googleapis.com",
                   "https://cdn.jsdelivr.net",
                   "https://db.onlinewebfonts.com"

  policy.font_src :self,
                  "https://fonts.gstatic.com",
                  "https://db.onlinewebfonts.com",
                  :data

  policy.img_src :self,
                 "https://res.cloudinary.com",
                 :data,
                 :https

  policy.connect_src :self,
                     "https://challenges.cloudflare.com"

  policy.frame_src "https://challenges.cloudflare.com"

  policy.object_src :none
  policy.base_uri :self
  policy.form_action :self
end

Rails.application.config.content_security_policy_report_only = false
