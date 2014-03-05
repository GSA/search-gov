class BoostedContentKeyword < ActiveRecord::Base
  extend AttributeSquisher

  before_validation_squish :value

  validates_presence_of :value
  validates_uniqueness_of :value, scope: :boosted_content_id, case_sensitive: false
  validates_format_of :value, with: /\A[^,|]+\z/i, message: "can't contain commas or pipes. Add each keyword (word or phrase) individually by clicking Add Another Keyword."
  belongs_to :boosted_content
end
