# frozen_string_literal: true

ADMIN_EMAIL_ADDRESS = Rails.application.secrets.organization[:admin_email_address].freeze
DEFAULT_USER_AGENT = Rails.application.secrets.organization[:default_user_agent].freeze
DELIVER_FROM_EMAIL_ADDRESS = 'no-reply@support.digitalgov.gov'.freeze
NOTIFICATION_SENDER_EMAIL_ADDRESS = 'notification@support.digitalgov.gov'.freeze
SEARCH_ENGINES = %w[BingV6 BingV7 Google SearchGov].freeze
SUPPORT_EMAIL_ADDRESS = Rails.application.secrets.organization[:support_email_address].freeze