class SearchgovUrl < ActiveRecord::Base
  include Fetchable
  include RobotsTaggable

  attr_accessible :last_crawl_status, :last_crawled_at, :url
  attr_reader :response, :document

  validate :unique_link

  before_validation :omit_query

  class SearchgovUrlError < StandardError; end

  def fetch
    self.last_crawled_at = Time.now
    self.load_time = Benchmark.realtime do
      DocumentFetchLogger.new(url, 'searchgov_url').log
      begin
        @response = HTTP.headers(user_agent: DEFAULT_USER_AGENT).follow.get(url)
        validate_response
        self.url = response.uri.to_s

        @document = parse_document
        validate_document
        index_document

        self.last_crawl_status = OK_STATUS
      rescue => error
        self.last_crawl_status = error.message
        Rails.logger.error "Unable to index #{url} into searchgov:\n#{error}\n#{error.backtrace.first}"
      end
    end
    save!
  end

  private

  def validate_response
    raise SearchgovUrlError.new(response.code) unless response.code == 200
    raise SearchgovUrlError.new("Redirection forbidden to #{response.uri}") if redirected_outside_domain?
    raise SearchgovUrlError.new('Noindex per X-Robots-Tag header') if noindex?
  end

  def validate_document
    raise SearchgovUrlError.new('Noindex per HTML metadata') if document.noindex?
  end

  def index_document
    Rails.logger.info "Indexing Searchgov URL #{url} into I14y"
    I14yDocument.create(
                         document_id: url_without_protocol,
                         handle: 'searchgov',
                         path: url,
                         title: document.title,
                         content: document.parsed_content,
                         description: document.description,
                         language: document.language,
                         tags: document.keywords,
                         created: Time.now,
                       )
  end

  def omit_query
    uri = Addressable::URI.parse(url)
    self.url = uri.try(:omit, :query).to_s
  end

  def unique_link
    conditions = ['((url = ? OR url = ?))',
                  "http://#{url_without_protocol}",
                  "https://#{url_without_protocol}"]
    id_conditions = persisted? ? ['id != ?',id] : []
    if SearchgovUrl.where(conditions).where(id_conditions).any?
      errors.add(:url, 'has already been taken')
    end
  end

  def url_without_protocol
    UrlParser.strip_http_protocols(url)
  end

  def parse_document
    HtmlDocument.new(document: response.to_s, url: url)
  end

  def redirected_outside_domain?
    PublicSuffix.domain(URI(url).host) != PublicSuffix.domain(response.uri.host)
  end

  def robots_directives
    headers = response.headers.to_hash
    RobotsTagParser.get_rules(headers: headers, user_agent: DEFAULT_USER_AGENT)
  end
end
