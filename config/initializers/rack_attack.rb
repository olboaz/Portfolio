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

  self.throttled_responder = lambda do |_request|
    [
      429,
      { "Content-Type" => "text/plain; charset=utf-8" },
      ["Trop de tentatives. Veuillez réessayer plus tard."]
    ]
  end
end