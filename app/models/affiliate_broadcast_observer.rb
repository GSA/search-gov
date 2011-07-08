class AffiliateBroadcastObserver < ActiveRecord::Observer
  @queue = :usasearch

  def after_save(affiliate_broadcast)
    Resque.enqueue(SendAffiliateBroadcast, affiliate_broadcast.subject, affiliate_broadcast.body)
  end
end
