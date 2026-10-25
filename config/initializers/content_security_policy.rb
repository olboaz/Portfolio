# Content Security Policy (CSP).
# Enforced in development and production.

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self

  policy.script_src :self,
                  "https://challenges.cloudflare.com",
                  "https://www.googletagmanager.com"

  policy.style_src :self, "https://fonts.googleapis.com"

  policy.font_src :self,
                  "https://fonts.gstatic.com",
                  "https://db.onlinewebfonts.com"

  policy.img_src :self,
               "https://res.cloudinary.com",
               "https://www.google-analytics.com",
               :data, :blob

  policy.connect_src :self,
                   "https://challenges.cloudflare.com",
                   "https://www.google-analytics.com",
                   "https://region1.google-analytics.com"

  policy.frame_src "https://challenges.cloudflare.com"

  policy.object_src :none
  policy.base_uri :self
  policy.form_action :self
  policy.frame_ancestors :none
end

Rails.application.config.content_security_policy_report_only = false

# Nonce CSP unique par requête pour les styles dynamiques de Turbo 8.
Rails.application.config.content_security_policy_nonce_generator = ->(request) {
  SecureRandom.base64(16)
}

Rails.application.config.content_security_policy_nonce_directives = %w[style-src]
