class ExcludedUrl < ActiveRecord::Base
  validates_presence_of :url, :affiliate_id
  validates_uniqueness_of :url, :scope => :affiliate_id, :case_sensitive => false
  validates_format_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix, allow_blank: true
  belongs_to :affiliate
  before_validation :ensure_http_prefix
  before_validation :unescape_url

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
