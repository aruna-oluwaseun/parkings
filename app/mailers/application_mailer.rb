class ApplicationMailer < ActionMailer::Base
  include ActionView::Helpers::TranslationHelper
  add_template_helper(ApplicationHelper)
  default from: "#{ENV['MAIL_SENDER_NAME']} <#{ENV['MAIL_FROM']}>"
  layout 'mailer'
end
