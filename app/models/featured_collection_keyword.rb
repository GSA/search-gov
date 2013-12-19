class FeaturedCollectionKeyword < ActiveRecord::Base
  validates_presence_of :value
  validates_uniqueness_of :value, scope: :featured_collection_id, case_sensitive: false
  validates_format_of :value, with: /^[^,|]+$/i, message: 'must be a single keyword per entry. Add separate keywords individually by clicking Add Another Keyword.'
  belongs_to :featured_collection
end
