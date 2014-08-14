class InstagramProfile < ActiveRecord::Base
  attr_accessible :id, :username

  has_and_belongs_to_many :affiliates

  validates_presence_of :id, :username
  validates_uniqueness_of :id

  after_create :notify_oasis

  private

  def notify_oasis
    Oasis.subscribe_to_instagram(self.id, self.username)
  end
end
