class SearchgovDomain < ActiveRecord::Base
  include AASM
  class DomainError < StandardError; end

  OK_STATUS = '200 OK'.freeze

  before_validation(on: :create) { self.domain = self.domain&.downcase&.strip }

  validate :valid_domain?, on: :create
  validates_inclusion_of :scheme, in: %w(http https)
  validates_uniqueness_of :domain, on: :create

  after_create { SearchgovDomainPreparerJob.perform_later(searchgov_domain: self) }

  has_many :searchgov_urls, dependent: :destroy
  has_many :sitemaps, dependent: :destroy

  attr_readonly :domain

  scope :ok, -> { where(status: OK_STATUS) }
  scope :not_ok, -> { where.not(status: OK_STATUS) }

  def delay
    @delay ||= begin
      robotex.delay("http://#{domain}/") || 1
    end
  end

  def index_urls
    index!
    SearchgovDomainIndexerJob.perform_later(searchgov_domain: self, delay: delay)
  rescue AASM::InvalidTransition
    Rails.logger.warn("#{domain} is already being indexed")
  end

  def index_sitemaps
    sitemap_urls.each{ |url| SitemapIndexerJob.perform_later(sitemap_url: url) }
  end

  def available?
    /^200\b/ === (status || check_status)
  end

  def check_status
    self.status = response.status
    self.scheme = response.uri.scheme
    self.canonical_domain = host unless domain == host

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

  def sitemap_urls
    urls = sitemaps.pluck(:url)
    urls += robotex.sitemaps(url).uniq.
             reject{ |url| URI(url).host != domain }.
             map{ |url| UrlParser.update_scheme(url, scheme) }
    urls.presence || ["#{url}sitemap.xml"]
  end

  private

  def robotex
    @robotex ||= Robotex.new 'usasearch'
  end

  def valid_domain?
    errors.add(:domain, 'is invalid') unless PublicSuffix.valid?(domain)
  end

  def response
    @response ||= begin
      Retriable.retriable(base_interval: delay) do
        DocumentFetchLogger.new(url, 'searchgov_domain').log
        HTTP.headers(user_agent: DEFAULT_USER_AGENT).timeout(connect: 20, read: 60).follow.get url
      end
    rescue => error
      self.update_attributes(status: error.message.strip)
      raise DomainError.new("#{domain}: #{error}")
    end
  end

  def url
    "#{scheme}://#{domain}/"
  end

  def host
    response.uri.host
  end
end
