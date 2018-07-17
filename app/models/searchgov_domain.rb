class SearchgovDomain < ActiveRecord::Base
  include AASM
  class DomainError < StandardError; end

  before_validation(on: :create) { self.domain = self.domain&.downcase&.strip }

  validate :valid_domain?, on: :create
  validates_inclusion_of :scheme, in: %w(http https)
  validates_uniqueness_of :domain, on: :create

  after_create { SearchgovDomainPreparerJob.perform_later(searchgov_domain: self) }

  has_many :searchgov_urls, dependent: :destroy
  has_many :sitemaps, dependent: :destroy

  attr_readonly :domain

  def delay
    @delay ||= begin
      robotex = Robotex.new 'usasearch'
      robotex.delay("http://#{domain}/") || 1
    end
  end

  def index_urls
    index!
    SearchgovDomainIndexerJob.perform_later(searchgov_domain: self, delay: delay)
  rescue AASM::InvalidTransition
    Rails.logger.warn("#{domain} is already being indexed")
  end

  def index_sitemap
    SitemapIndexerJob.perform_later(searchgov_domain: self)
  end

  def available?
    /^200\b/ === (status || check_status)
  end

  def check_status
    self.status, self.scheme = current_status, response.uri.scheme
    save if changed?
    status
  end

  aasm column: 'activity' do
    state :idle, initial: true
    state :indexing

    event :index do
      transitions from: :idle, to: :indexing
    end

    event :done_indexing do
      transitions from: :indexing, to: :idle
    end
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
      raise DomainError.new("#{domain}: #{error}")
    end
  end

  def url
    "#{scheme}://#{domain}/"
  end

  def current_status
    response.uri.host != domain ? "Canonical domain: #{response.uri.host}" : response.status
  end
end
