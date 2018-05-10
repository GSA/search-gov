class SearchgovDomain < ActiveRecord::Base
  validate :valid_domain?, on: :create
  has_many :searchgov_urls, dependent: :destroy

  attr_readonly :domain

  def delay
    @delay ||= begin
      robotex = Robotex.new 'usasearch'
      robotex.delay("http://#{domain}/") || 1
    end
  end

  def index_urls
    SearchgovDomainIndexerJob.perform_later(self, delay)
  end

  def scheme
    begin
      response = open("http://#{domain}/", allow_redirections: :safe, 'User-Agent' => DEFAULT_USER_AGENT)
      response.base_uri.scheme
    rescue => error
      self.update_attributes(status: error.message.strip)
      raise
    end
  end

  def index_sitemap
    SitemapIndexer.new(domain: domain, delay: delay, scheme: scheme).index
  end

  private

  def valid_domain?
    errors.add(:domain, 'is invalid') unless PublicSuffix.valid?(domain)
  end
end
