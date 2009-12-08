class AffiliateBroadcast < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :subject
  validates_presence_of :body
  after_save :broadcast

  private

  def broadcast
    done = {}
    Affiliate.all.each do |affiliate|
      next if affiliate.contact_email.blank? or done[affiliate.contact_email]
      done[affiliate.contact_email] = true
      affiliate_ids = Affiliate.find_all_by_contact_email(affiliate.contact_email).collect{|a| a.name}
      AffiliateEmailer.deliver_email(affiliate, self.subject, self.body, affiliate_ids)
    end
  end
end
