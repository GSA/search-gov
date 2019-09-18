class FeaturedCollectionKeyword < ApplicationRecord
  include BelongsToFeaturedCollectionDupable

  validates_presence_of :value
  validates_uniqueness_of :value, scope: :featured_collection_id, case_sensitive: false
  validates_format_of :value, with: /\A[^,|]+\z/i, message: "can't contain commas or pipes. Add each keyword (word or phrase) individually by clicking Add Another Keyword."
  belongs_to :featured_collection
end
