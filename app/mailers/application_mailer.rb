# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@support.digitalgov.gov',
          reply_to: Rails.application.secrets.organization[:support_email_address]
  layout 'mailer'
end