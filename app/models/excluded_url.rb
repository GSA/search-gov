class ExcludedUrl < ActiveRecord::Base
  before_validation :ensure_http_prefix
  validates_presence_of :url, :affiliate_id
  validates_uniqueness_of :url, :scope => :affiliate_id, :case_sensitive => false
  validates_url :url, allow_blank: true
  belongs_to :affiliate
  before_save :unescape_url

  private

  def ensure_http_prefix
    return if url.blank?
    self.url = url.strip
    self.url = "http://#{url}" unless url =~ %r{^https?://}i
  end

  def unescape_url
    self.url = URI.unescape(self.url) if self.url
  end
end
