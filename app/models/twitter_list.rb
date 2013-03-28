class TwitterList < ActiveRecord::Base
  self.primary_key = 'id'
  serialize :member_ids, Array
  attr_accessible :last_status_id, :member_ids, :statuses_updated_at
  validates_numericality_of :id, only_integer: true, greater_than: 0
  has_and_belongs_to_many :twitter_profiles
end