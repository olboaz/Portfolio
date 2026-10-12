require "net/http"
require "json"

class SecuritySlackNotifier
  def self.call(message)
    webhook_url = ENV["SLACK_SECURITY_WEBHOOK_URL"]
    return nil if webhook_url.blank?

    uri = URI.parse(webhook_url)

    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: true,
      open_timeout: 3,
      read_timeout: 5
    ) do |http|
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = { text: message }.to_json

      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      true
    else
      Rails.logger.warn(
        "[SecuritySlackNotifier] Slack HTTP #{response.code}"
      )
      false
    end
  rescue StandardError => e
    Rails.logger.warn(
      "[SecuritySlackNotifier] Notification impossible : #{e.class}"
    )
    nil
  end
end