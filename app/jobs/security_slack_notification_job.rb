class SecuritySlackNotificationJob < ApplicationJob
  queue_as :default

  def perform(message)
    SecuritySlackNotifier.call(message)
  end

  def self.notify(message)
    perform_later(message)
  rescue StandardError => e
    Rails.logger.warn(
      "[SecuritySlackNotificationJob] Programmation impossible : #{e.class}"
    )
    nil
  end
end