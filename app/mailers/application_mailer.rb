# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  ADMIN_EMAIL_ADDRESS = Rails.application.secrets.organization[:admin_email_address]
  DELIVER_FROM_EMAIL_ADDRESS = 'no-reply@support.digitalgov.gov'
  REPLY_TO_EMAIL_ADDRESS = Rails.application.secrets.organization[:support_email_address]
  NOTIFICATION_SENDER_EMAIL_ADDRESS = 'notification@support.digitalgov.gov'

  default from: DELIVER_FROM_EMAIL_ADDRESS,
          reply_to: REPLY_TO_EMAIL_ADDRESS
  layout 'mailer'
end
