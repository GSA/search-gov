class FeaturedCollectionLink < ActiveRecord::Base
  validates_presence_of :title, :url
  belongs_to :featured_collection
  before_save :ensure_http_prefix_on_url

  private
  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^http(s?)://}i
  end
end
