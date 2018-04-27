class SearchgovDomain < ActiveRecord::Base
  before_validation(on: :create) { self.domain = self.domain&.downcase&.strip }

  validate :valid_domain?, on: :create
  validates_inclusion_of :scheme, in: %w(http https)
  validates_uniqueness_of :domain, on: :create

  after_create { SearchgovDomainPreparerJob.perform_later(searchgov_domain: self) }

  has_many :searchgov_urls, dependent: :destroy

  attr_readonly :domain

  def delay
    @delay ||= begin
      robotex = Robotex.new 'usasearch'
      robotex.delay("http://#{domain}/") || 1
    end
  end

  def index_urls
    SearchgovDomainIndexerJob.perform_later(searchgov_domain: self, delay: delay)
  end

  def index_sitemap
    SitemapIndexer.new(site: url, delay: delay).index
  end

  def available?
    /^200\b/ === (status || check_status)
  end

  def check_status
    self.status, self.scheme = current_status, response.uri.scheme
    save if changed?
    status
  end

  private

  def valid_domain?
    errors.add(:domain, 'is invalid') unless PublicSuffix.valid?(domain)
  end

  def response
    @response ||= begin
      DocumentFetchLogger.new(url, 'searchgov_domain').log
      HTTP.headers(user_agent: DEFAULT_USER_AGENT).timeout(connect: 20, read: 60).follow.get url
    rescue => error
      self.update_attributes(status: error.message.strip)
      raise
    end
  end

  def url
    "#{scheme}://#{domain}/"
  end

  def current_status
    response.uri.host != domain ? "Canonical domain: #{response.uri.host}" : response.status
  end
end
