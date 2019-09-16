class FeaturedCollectionLink < ApplicationRecord
  include BelongsToFeaturedCollectionDupable

  before_validation do |record|
    AttributeProcessor.sanitize_attributes record, :title
    AttributeProcessor.squish_attributes record, :title, :url
    AttributeProcessor.prepend_attributes_with_http record, :url
  end

  validates_presence_of :title, :url
  belongs_to :featured_collection

  def as_json(options = {})
    { title: title, url: url }
  end
end
