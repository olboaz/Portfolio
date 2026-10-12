require "test_helper"
require "minitest/mock"
require "net/http"

class SecuritySlackNotifierTest < ActiveSupport::TestCase
  test "does nothing when webhook is not configured" do
    ENV.stub("[]", nil) do
      Net::HTTP.stub(:start, ->(*) { flunk "HTTP should not be called" }) do
        assert_nil SecuritySlackNotifier.call("Test")
      end
    end
  end

  test "sends a notification to Slack" do
    ENV.stub("[]", "https://hooks.slack.com/services/test") do
      response = Net::HTTPOK.new("1.1", "200", "OK")

      http = Object.new

      http.define_singleton_method(:request) do |request|
        raise "Expected POST" unless request.method == "POST"
        raise "Missing message" unless request.body.include?("Security alert")

        response
      end

      http_mock = lambda do |*args, **kwargs, &block|
        block.call(http)
      end

      Net::HTTP.stub(:start, http_mock) do
        assert_equal true, SecuritySlackNotifier.call("Security alert")
      end
    end
  end

  test "does not crash when Slack is unavailable" do
    ENV.stub("[]", "https://hooks.slack.com/services/test") do
      Net::HTTP.stub(
        :start,
        ->(*args, **kwargs, &block) { raise Timeout::Error, "Connection timed out" }
      ) do
        assert_nil SecuritySlackNotifier.call("Security alert")
      end
    end
  end
end