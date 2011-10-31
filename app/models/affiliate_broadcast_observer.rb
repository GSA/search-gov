class AffiliateBroadcastObserver < ActiveRecord::Observer
  def after_save(affiliate_broadcast)
    Resque.enqueue(SendAffiliateBroadcast, affiliate_broadcast.subject, affiliate_broadcast.body)
  end
end
