class AssetCacheHeaders
  FINGERPRINTED_ASSET = %r{\A/assets/.+-[0-9a-f]{32,}\.[^/]+\z}

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    path = env["PATH_INFO"].to_s

    if (status == 200 || status == 304) &&
       env["REQUEST_METHOD"].to_s.match?(/\A(?:GET|HEAD)\z/) &&
       FINGERPRINTED_ASSET.match?(path)
      headers["cache-control"] = "public, max-age=31536000, immutable"
    end

    [status, headers, body]
  end
end
