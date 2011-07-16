class FeaturedCollectionLink < ActiveRecord::Base
  validates_presence_of :title, :url
  belongs_to :featured_collection
end
