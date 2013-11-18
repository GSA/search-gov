class FeaturedCollectionLink < ActiveRecord::Base
  validates_presence_of :title, :url
  belongs_to :featured_collection
  before_save :ensure_http_prefix_on_url

  class << self
    def grep(featured_collection_ids, query)
      substring_search_fields = %w(title url)
      field_clauses = substring_search_fields.collect { |field| "#{field} LIKE ?" }
      values = Array.new(substring_search_fields.size, "%#{query}%")
      where(featured_collection_id: featured_collection_ids).where(field_clauses.join(" OR "), *values)
    end
  end

  private
  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^http(s?)://}i
  end
end
