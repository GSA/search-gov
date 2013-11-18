class FeaturedCollectionKeyword < ActiveRecord::Base
  validates_presence_of :value
  validates_uniqueness_of :value, :scope => :featured_collection_id, :case_sensitive => false
  belongs_to :featured_collection

  class << self
    def grep(featured_collection_ids, query)
      substring_search_fields = %w(value)
      field_clauses = substring_search_fields.collect { |field| "#{field} LIKE ?" }
      values = Array.new(substring_search_fields.size, "%#{query}%")
      where(featured_collection_id: featured_collection_ids).where(field_clauses.join(" OR "), *values)
    end
  end

end
