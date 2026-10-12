class Rack::Attack
  self.cache.store = ActiveSupport::Cache::MemoryStore.new(
    size: 10.megabytes
  )

  throttle("contacts/ip", limit: 2, period: 30.minutes) do |req|
    req.ip if req.post? && req.path == "/contacts"
  end
  
  # Connexion Devise : 5 tentatives maximum par IP en 15 minutes
  throttle("logins/ip", limit: 5, period: 15.minutes) do |req|
    req.ip if req.post? && req.path == "/users/sign_in"
  end

  # Détection des chemins fréquemment utilisés par les scanners
  SUSPICIOUS_PATHS = [
    %r{\A/api/v1/(?:login|auto_login|users)(?:/|\z)}i,
    %r{\A/wp-admin(?:/|\z)}i,
    %r{\A/wp-login\.php\z}i,
    %r{\A/\.env(?:\..*)?\z}i,
    %r{\A/\.git(?:/|\z)}i
  ].freeze

  safelist("security/scan_observation") do |req|
    if SUSPICIOUS_PATHS.any? { |pattern| pattern.match?(req.path) }
      Rails.logger.warn(
        "[SecurityScan] IP=#{req.ip} path=#{req.path}"
      )
      # Limitation des notifications de scans
      alert_cache = Rack::Attack.cache.store

      ip_key = "security:slack:scan:#{req.ip}"

      first_alert = alert_cache.write(
        ip_key,
        true,
        expires_in: 30.minutes,
        unless_exist: true
      )

      if first_alert
        global_key = "security:slack:global:#{Time.current.to_i / 3600}"

        global_count = alert_cache.increment(
          global_key,
          1,
          expires_in: 1.hour
        )

        if global_count <= 10
          SecuritySlackNotificationJob.notify(
            "🔎 *Portfolio — Scan suspect détecté*\n" \
            "IP : #{req.ip}\n" \
            "Chemin : #{req.path}\n" \
            "Action : surveillance (HTTP 404)"
          )
        end
      end
    end

    false
  end

  self.throttled_responder = lambda do |_request|
    [
      429,
      { "Content-Type" => "text/plain; charset=utf-8" },
      ["Trop de tentatives. Veuillez réessayer plus tard."]
    ]
  end

  # Notification lorsqu'une tentative de connexion est bloquée
  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
    request = payload[:request]

    next unless request.env["rack.attack.matched"] == "logins/ip"

    ip = request.ip

    # Une notification maximum par IP toutes les 15 minutes
    alert_key = "security:slack:login:#{ip}"

    alert_cache = Rack::Attack.cache.store

    # Une seule notification par IP sur cette période
    next unless alert_cache.write(
      alert_key,
      true,
      expires_in: 15.minutes,
      unless_exist: true
    )

    # Maximum 10 alertes Slack par heure, toutes IP confondues
    global_key = "security:slack:global:#{Time.current.to_i / 3600}"

    global_count = alert_cache.increment(
      global_key,
      1,
      expires_in: 1.hour
    )

    next if global_count > 10

    SecuritySlackNotificationJob.notify(
      "🚨 *Portfolio — Tentatives de connexion bloquées*\n" \
      "IP : #{ip}\n" \
      "Route : /users/sign_in\n" \
      "Protection : Rack::Attack (HTTP 429)"
    )
  end

end