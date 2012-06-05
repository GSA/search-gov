class TwitterProfile < ActiveRecord::Base
  has_many :tweets, :primary_key => :twitter_id, :dependent => :destroy
  has_and_belongs_to_many :affiliates
  validates_presence_of :twitter_id, :screen_name, :profile_image_url
  validates_uniqueness_of :twitter_id, :screen_name

  def link_to_profile
    "http://twitter.com/#!/#{screen_name}"
  end
end
