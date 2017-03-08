class SiteDestroyer
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary

  def self.perform(site_id)
    Affiliate.find(site_id).destroy
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn "Cannot find site to destroy: #{e}"
  end
end
