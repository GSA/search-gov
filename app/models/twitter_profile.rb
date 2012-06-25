class TwitterProfile < ActiveRecord::Base
  has_many :tweets, :primary_key => :twitter_id, :dependent => :destroy
  has_and_belongs_to_many :affiliates
  validates_presence_of :twitter_id, :screen_name, :profile_image_url
  validates_uniqueness_of :twitter_id, :screen_name
  before_validation :lookup_twitter_id
  
  def link_to_profile
    "http://twitter.com/#!/#{screen_name}"
  end
  
  private
  
  def lookup_twitter_id
    if self.screen_name and self.twitter_id.nil?
      twitter_user = Twitter.user(self.screen_name) rescue nil
      self.twitter_id = twitter_user.id if twitter_user
    end
  end
end
