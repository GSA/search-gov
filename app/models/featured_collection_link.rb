class FeaturedCollectionLink < ActiveRecord::Base
  extend AttributeSquisher

  before_validation :sanitize_html_in_title
  before_validation_squish :title, :url
  validates_presence_of :title, :url
  belongs_to :featured_collection
  before_save :ensure_http_prefix_on_url

  def as_json(options = {})
    { title: title, url: url }
  end

  private
  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^http(s?)://}i
  end

  def sanitize_html_in_title
    self.title = Sanitize.clean(self.title)
  end

end
