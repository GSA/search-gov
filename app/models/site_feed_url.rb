class SiteFeedUrl < ApplicationRecord
  include Dupable

  HUMAN_ATTRIBUTE_NAME_HASH = { rss_url: 'URL' }
  belongs_to :affiliate
  before_validation NormalizeUrl.new(:rss_url)
  validates_presence_of :rss_url
  after_destroy :fast_destroy_indexed_rss_docs

  def self.refresh_all
    select(:id).each do |site_feed_url|
      Resque.enqueue_with_priority(:low, SiteFeedUrlFetcher, site_feed_url.id)
    end
  end

  def self.human_attribute_name(attribute_key_name, options = {})
    HUMAN_ATTRIBUTE_NAME_HASH[attribute_key_name.to_sym] || super
  end

  private

  def fast_destroy_indexed_rss_docs
    indexed_rss_docs = IndexedDocument.select(:id).where(affiliate_id: self.affiliate.id, source: 'rss')
    ids = indexed_rss_docs.collect(&:id)
    ElasticIndexedDocument.delete(ids)
    indexed_rss_docs.delete_all
  end
end
