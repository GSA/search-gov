class ExcludedUrl < ActiveRecord::Base
  include Dupable

  before_validation :ensure_http_prefix
  validates_presence_of :url, :affiliate_id
  validates_uniqueness_of :url, :scope => :affiliate_id, :case_sensitive => false
  validates_url :url, allow_blank: true
  belongs_to :affiliate
  before_save :decode_url, if: :url?

  private

  def ensure_http_prefix
    return if url.blank?
    self.url = url.strip
    self.url = "http://#{url}" unless url =~ %r{^https?://}i
  end

  def decode_url
    self.url = valid_utf8_or_bust(URI.decode_www_form_component(url))
  end

  def valid_utf8_or_bust(str)
    encoded = str.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    encoded == str ? str : nil
  end
end
