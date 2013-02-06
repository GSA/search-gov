class HelpLink < ActiveRecord::Base
  before_validation :filter_request_path, if: :request_path?
  validates_presence_of :request_path, :help_page_url
  validates_uniqueness_of :request_path
  validates :request_path, format: { with: /^(\/[a-z_]+)+$/ }

  def self.sanitize_request_path(request_path)
    URI.parse(request_path).path.gsub(/\/[0-9]+/, '').gsub(/\/$/, '')
  end

  private

  def filter_request_path
    self.request_path = HelpLink.sanitize_request_path(request_path.strip)
  end
end
