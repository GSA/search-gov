# frozen_string_literal: true

ADMIN_EMAIL_ADDRESS = Rails.application.secrets.organization[:admin_email_address]
DEFAULT_USER_AGENT = Rails.application.secrets.organization[:default_user_agent]
DELIVER_FROM_EMAIL_ADDRESS = 'no-reply@support.digitalgov.gov'
NOTIFICATION_SENDER_EMAIL_ADDRESS = 'notification@support.digitalgov.gov'
SEARCH_ENGINES = %w[BingV6 BingV7 SearchGov].freeze
SUPPORT_EMAIL_ADDRESS = Rails.application.secrets.organization[:support_email_address]
