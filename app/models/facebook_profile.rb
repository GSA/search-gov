class FacebookProfile < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :username, :affiliate
  validates_uniqueness_of :username, :scope => :affiliate_id
  
  before_validation :normalize_username
  
  private
  
  def normalize_username
    self.username.strip! unless self.username.nil?
  end
end
