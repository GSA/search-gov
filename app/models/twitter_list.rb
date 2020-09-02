class TwitterList < ApplicationRecord
  self.primary_key = 'id'
  serialize :member_ids, Array
  validates_numericality_of :id, only_integer: true, greater_than: 0
  has_and_belongs_to_many :twitter_profiles, join_table: :twitter_lists_twitter_profiles
  scope :active, -> {
    joins(twitter_profiles: [:affiliate_twitter_settings]).
      where('affiliate_twitter_settings.show_lists = 1').distinct
  }
  scope :statuses_updated_before, ->(time) {
    where('statuses_updated_at IS NULL OR statuses_updated_at < ?', time)
  }
end
