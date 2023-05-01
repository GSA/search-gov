# frozen_string_literal: true

module Fetchable
  extend ActiveSupport::Concern

  OK_STATUS = 'OK'
  UNSUPPORTED_EXTENSION = 'URL extension is not one we index'
  BLACKLISTED_EXTENSIONS =
    %w[
       bz
       bz2
       css
       csv
       epub
       exe
       gif
       gz
       htc
       ico
       jar
       jpeg
       jpg
       js
       json
       kmz
       m4v
       mobi
       mov
       mp3
       mp4
       png
       rss
       swf
       tar
       tgz
       wav
       wmv
       wsdl
       xml
       z
       zip
    ].freeze

  included do
    scope :ok, -> { where(last_crawl_status: OK_STATUS) }
    scope :not_ok,
          lambda {
            where("last_crawl_status <> '#{OK_STATUS}' OR ISNULL(last_crawled_at)")
          }
    scope :fetched, -> { where('last_crawled_at IS NOT NULL') }
    # For indexed documents, last_crawled_at may be nil,
    # while last_crawl_status may be "summarized"
    scope :unfetched, -> { where('ISNULL(last_crawled_at)') }

    before_validation :normalize_url
    before_validation do
      truncate_value(:last_crawl_status, 255)
    end
    before_validation :escape_url
    validates :url, length: { maximum: 2000 }
    validates :url, presence: true
    validates_url :url, allow_blank: true
  end

  def fetched?
    last_crawled_at.present?
  end

  def indexed?
    last_crawl_status == OK_STATUS
  end

  private

  def self_url
    @self_url ||= URI.parse(url) rescue nil
  end

  def normalize_url
    return if url.blank?

    ensure_prefix_on_url
    downcase_scheme_and_host_and_remove_anchor_tags
  end

  def ensure_prefix_on_url
    self.url = "https://#{url}" unless url.blank? || url =~ %r{^https?://}i
    @self_url = nil
  end

  def downcase_scheme_and_host_and_remove_anchor_tags
    if self_url
      host = self_url.host.downcase
      request = self_url.request_uri.gsub(%r{/+}, '/')
      self.url = "#{scheme}://#{host}#{request}"
      @self_url = nil
    end
  end

  def url_extension
    Addressable::URI.parse(url).extname.downcase.from(1)
  end

  def set_searchgov_domain
    self.searchgov_domain = SearchgovDomain.find_by(domain: URI(url).host)
  end

  def escape_url
    self.url = Addressable::URI.normalized_encode(url) rescue ''
  end

  def scheme
    'https'
  end
end
