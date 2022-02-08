# frozen_string_literal: true

class HelpLink < ApplicationRecord
  before_validation :filter_request_path, if: :request_path?
  validates_presence_of :request_path, :help_page_url
  validates_uniqueness_of :request_path, case_sensitive: true
  validates :request_path, format: { with: /\A(\/[a-z0-9_]+)+\z/ }

  def self.sanitize_request_path(request_path)
    URI.parse(request_path).path.gsub(/\/[0-9]+/, '').gsub(/\/$/, '')
  rescue URI::InvalidURIError => e
    # Rails 3.x returns nil when request.path has no matching route, but
    # Rails 4.x raises URI::InvalidURIError. Emulate the old behavior here.
    raise if e.message !~ /No route matches/
  end

  def self.lookup request, action_name
    help_link_key = sanitize_request_path request.path
    unless request.get?
      action_hash = { create: 'new', update: 'edit' }
      help_link_key << "/#{action_hash[action_name.to_sym] || action_name}"
    end
    find_by_request_path help_link_key
  end

  private

  def filter_request_path
    self.request_path = HelpLink.sanitize_request_path(request_path.strip)
  end
end
