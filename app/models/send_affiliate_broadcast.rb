class SendAffiliateBroadcast
  @queue = :usasearch

  def self.perform(subject, body)
    User.where(:is_affiliate=>true).each do |affiliate_user|
      AffiliateEmailer.email(affiliate_user, subject, body).deliver
    end
  end
end