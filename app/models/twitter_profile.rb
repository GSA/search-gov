class TwitterProfile < ActiveRecord::Base
  has_many :tweets, :primary_key => :twitter_id, :dependent => :destroy
  has_and_belongs_to_many :affiliates
  validates_presence_of :twitter_id, :screen_name
  validates_uniqueness_of :twitter_id, :screen_name
end
