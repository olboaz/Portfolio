require "test_helper"
require "minitest/mock"

class SecuritySlackNotificationJobTest < ActiveJob::TestCase
  test "sends the message through SecuritySlackNotifier" do
    messages = []

    notifier = lambda do |message|
      messages << message
      true
    end

    SecuritySlackNotifier.stub(:call, notifier) do
      SecuritySlackNotificationJob.perform_now("Alerte sécurité")
    end

    assert_equal ["Alerte sécurité"], messages
  end
end