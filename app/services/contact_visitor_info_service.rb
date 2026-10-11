require "resolv"
require "net/http"
require "json"
require "ipaddr"
require "timeout"

class ContactVisitorInfoService
  def self.call(request)
    ip = request.remote_ip
    geo = lookup_geo(ip)

    {
      ip: ip,
      country: geo["country"] || "Inconnu",
      country_code: geo["country_code"] || "??",
      city: geo["city"] || "Inconnue",
      isp: geo.dig("connection", "isp") || "Inconnu",
      asn: geo.dig("connection", "asn") || "Inconnu",
      hostname: resolve_hostname(ip),
      user_agent: request.user_agent.presence || "Inconnu",
      language: request.headers["Accept-Language"].presence || "Inconnue",
      referer: request.referer.presence || "Accès direct / inconnu",
      captured_at: Time.current
    }
  end

  def self.lookup_geo(ip)
    address = IPAddr.new(ip)
    return {} if address.private? || address.loopback? || address.link_local?

    uri = URI("https://ipwho.is/#{address}")

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true,
      open_timeout: 1,
      read_timeout: 1
    ) do |http|
      http.get(uri.request_uri)
    end

    return {} unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    data["success"] == true ? data : {}
  rescue StandardError => e
    Rails.logger.warn("GeoIP indisponible : #{e.class}")
    {}
  end

  def self.resolve_hostname(ip)
    Timeout.timeout(0.5) do
      Resolv.getname(ip)
    end
  rescue StandardError
    "Non disponible"
  end

  private_class_method :lookup_geo, :resolve_hostname
end
