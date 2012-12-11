class BoostedContentKeyword < ActiveRecord::Base
  validates_presence_of :value
  validates_uniqueness_of :value, :scope => :boosted_content_id
  belongs_to :boosted_content
end
