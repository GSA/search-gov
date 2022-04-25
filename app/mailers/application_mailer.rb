# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: DELIVER_FROM_EMAIL_ADDRESS,
          reply_to: SUPPORT_EMAIL_ADDRESS
  layout 'mailer'
end
