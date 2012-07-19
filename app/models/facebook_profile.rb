class FacebookProfile < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :username, :affiliate_id
  validates_uniqueness_of :username, :scope => :affiliate_id, :message => 'has already been added'

  before_validation :normalize_username

  def link_to_profile
    "http://www.facebook.com/#{self.username}"
  end

  private

  def normalize_username
    self.username.strip! unless self.username.nil?
  end
end
