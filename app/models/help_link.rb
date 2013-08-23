class HelpLink < ActiveRecord::Base
  before_validation :filter_request_path, if: :request_path?
  validates_presence_of :request_path, :help_page_url
  validates_uniqueness_of :request_path
  validates :request_path, format: { with: /^(\/[a-z_]+)+$/ }

  def self.sanitize_request_path(request_path)
    URI.parse(request_path).path.gsub(/\/[0-9]+/, '').gsub(/\/$/, '')
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
