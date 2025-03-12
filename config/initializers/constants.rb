# frozen_string_literal: true

ADMIN_EMAIL_ADDRESS               = ENV['ADMIN_EMAIL_ADDRESS']
DEFAULT_USER_AGENT                = ENV.fetch('DEFAULT_USER_AGENT', 'usasearch')
DELIVER_FROM_EMAIL_ADDRESS        = 'no-reply@support.digitalgov.gov'
NOTIFICATION_SENDER_EMAIL_ADDRESS = 'notification@support.digitalgov.gov'
SEARCH_ENGINES                    = %w[BingV7 SearchGov SearchElastic].freeze
SUPPORT_EMAIL_ADDRESS             = ENV['SUPPORT_EMAIL_ADDRESS']
BLOG_URL                          = ENV['BLOG_URL']
PAGE_NOT_FOUND_URL                = ENV['PAGE_NOT_FOUND_URL']
