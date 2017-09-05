module Fetchable
  extend ActiveSupport::Concern

  OK_STATUS = "OK"

  included do
    validates_length_of :url, maximum: 2000
    validates_presence_of :url
    validates_url :url, allow_blank: true
    before_validation :normalize_url
  end

  private

  def self_url
    @self_url ||= URI.parse(self.url) rescue nil
  end

  def normalize_url
    return if self.url.blank?
    ensure_prefix_on_url
    downcase_scheme_and_host_and_remove_anchor_tags
  end

  def ensure_prefix_on_url
    self.url = "https://#{self.url}" unless self.url.blank? or self.url =~ %r{^https?://}i
    @self_url = nil
  end

  def downcase_scheme_and_host_and_remove_anchor_tags
    if self_url
      scheme = self_url.scheme.downcase
      host = self_url.host.downcase
      request = self_url.request_uri.gsub(/\/+/, '/')
      self.url = "#{scheme}://#{host}#{request}"
      @self_url = nil
    end
  end
end
