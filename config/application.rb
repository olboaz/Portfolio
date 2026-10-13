require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Portfolio
  class Application < Rails::Application
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.i18n.default_locale = :fr
    # Limiter l'envoi des cookies lors des requêtes provenant d'autres sites.
    config.action_dispatch.cookies_same_site_protection = :lax
    # En-têtes de sécurité du portfolio.
    config.action_dispatch.default_headers.merge!(
      "Permissions-Policy" => "camera=(), microphone=(), geolocation=()",
      "X-XSS-Protection" => "0"
    )
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

  end
end
