# frozen_string_literal: true

# Domains whose pages are indexed into the 'searchgov' I14y drawer
# for searching via the SearchGov search engine
class SearchgovDomain < ApplicationRecord
  include AASM
  class DomainError < StandardError; end

  OK_STATUS        = '200 OK'
  INDEXING_STARTED = 'indexing started'
  INDEXING_STOPPED = 'indexing stopped'

  GOOD_STATUS = [OK_STATUS, INDEXING_STARTED, INDEXING_STOPPED]

  before_validation(on: :create) { self.domain = domain&.downcase&.strip }

  validates :domain, uniqueness: { case_sensitive: true }, on: :create
  validates :domain, presence: true,
                     format: { with: /\A([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\Z/ }

  after_create { SearchgovDomainPreparerJob.perform_later(searchgov_domain: self) }

  has_many :searchgov_urls, dependent: :destroy
  has_many :sitemaps, dependent: :destroy

  attr_readonly :domain
  attr_reader :response

  scope :ok, -> { where(status: GOOD_STATUS) }
  scope :not_ok, -> { where.not(status: GOOD_STATUS).or(where(status: nil)) }

  def to_label
    domain
  end

  def delay
    @delay ||= (robotex.delay(url) || 1)
  end

  def index_urls
    index!
    SearchgovDomainIndexerJob.perform_later(searchgov_domain: self, delay: delay)
  end

  def index_sitemaps
    sitemap_urls.each { |url| SitemapIndexerJob.perform_later(sitemap_url: url, domain: domain) }
  end

  def available?
     GOOD_STATUS.include? (status || check_status)
  end

  def check_status
    fetch_response
    validate_response
    status
  end

  aasm column: 'activity', whiny_transitions: false do
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
    urls += robotex.sitemaps(url).uniq.map { |url| UrlParser.update_scheme(url, 'https') }
    urls.presence || ["#{url}sitemap.xml"]
  end

  def stop_indexing!
    done_indexing
    self.status = INDEXING_STOPPED

    save
  end

  private

  def robotex
    @robotex ||= Robotex.new('usasearch')
  end

  def fetch_response
    @response = begin
      Retriable.retriable(base_interval: delay) do
        DocumentFetchLogger.new(url, 'searchgov_domain').log
        HTTP.headers(user_agent: DEFAULT_USER_AGENT).
          timeout(connect: 20, read: 60).follow.get(url)
      end
    rescue StandardError => e
      failed_response(e)
    end
  end

  def failed_response(err)
    update(status: err.message.strip)
    Rails.logger.error "#{domain} response error url: #{url} error: #{status}"
    nil
  end

  def validate_response
    if response
      record_response
    elsif activity == 'indexing'
      done_indexing!
    end
  end

  def record_response
    self.status = response.status
    self.canonical_domain = host unless domain == host

    save if changed?
  end

  def url
    "https://#{domain}/"
  end

  def host
    response.uri.host
  end
end
