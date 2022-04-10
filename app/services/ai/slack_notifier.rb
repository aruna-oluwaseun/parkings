module Ai
  class SlackNotifier

    AI_SLACK_NOTIFIER = Slack::Notifier.new ENV.fetch("AI_SLACK_NOTIFIER_WEBHOOK_URL") { '' } do
      defaults channel: ENV['AI_SLACK_NOTIFIER_WEBHOOK_CHANNEL'],
      username: ENV.fetch("AI_SLACK_NOTIFIER_WEBHOOK_USERNAME") { "ai-notifier" }
    end

    def self.ping(message)
      if ENV['AI_SLACK_NOTIFIER_WEBHOOK_URL'].present?
        AI_SLACK_NOTIFIER.ping message.to_s
      end
    rescue
    end
  end
end
