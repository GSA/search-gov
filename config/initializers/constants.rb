# frozen_string_literal: true

SEARCH_ENGINES = %w[BingV6 BingV7 Google SearchGov].freeze
DEFAULT_USER_AGENT = Rails.application.secrets.organization[:default_user_agent].freeze
