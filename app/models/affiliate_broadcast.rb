class AffiliateBroadcast < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :subject
  validates_presence_of :body
  after_save :broadcast

  private

  def broadcast
    User.find_all_by_is_affiliate(true).each do |affiliate_user|
      AffiliateEmailer.email(affiliate_user, self.subject, self.body).deliver
    end
  end
end
