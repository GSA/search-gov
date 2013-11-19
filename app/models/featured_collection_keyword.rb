class FeaturedCollectionKeyword < ActiveRecord::Base
  validates_presence_of :value
  validates_uniqueness_of :value, :scope => :featured_collection_id, :case_sensitive => false
  belongs_to :featured_collection

end
