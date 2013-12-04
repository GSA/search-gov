class FeaturedCollectionLink < ActiveRecord::Base
  validates_presence_of :title, :url
  belongs_to :featured_collection
  before_save :ensure_http_prefix_on_url, :sanitize_html_in_title

  private
  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^http(s?)://}i
  end

  def sanitize_html_in_title
    self.title = Sanitize.clean(self.title)
  end

end
