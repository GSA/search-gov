# frozen_string_literal: true

class TwitterList < ApplicationRecord
  self.primary_key = 'id'
  validates :id, numericality: { only_integer: true, greater_than: 0 }
  has_and_belongs_to_many :twitter_profiles, join_table: :twitter_lists_twitter_profiles
  scope :active, lambda {
    joins(twitter_profiles: [:affiliate_twitter_settings]).
      where('affiliate_twitter_settings.show_lists = 1').distinct
  }
  scope :statuses_updated_before, lambda { |time|
    where('statuses_updated_at IS NULL OR statuses_updated_at < ?', time)
  }
end
