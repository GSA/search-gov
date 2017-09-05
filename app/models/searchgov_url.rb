class SearchgovUrl < ActiveRecord::Base
  include Fetchable

  attr_accessible :last_crawl_status, :last_crawled_at, :url

  validate :unique_link

  before_validation :omit_query

  class SearchgovUrlError < StandardError; end

  def fetch
    self.last_crawled_at = Time.now
    self.load_time = Benchmark.realtime do
      DocumentFetchLogger.new(url, 'searchgov_url').log
      begin
        response = HTTP.headers(user_agent: DEFAULT_USER_AGENT).follow.get(url)
        validate_response(response)
        html = response.to_s
        self.url = response.uri.to_s
        index_document(html)
        self.last_crawl_status = OK_STATUS
      rescue => error
        self.last_crawl_status = error.message
        Rails.logger.error "Unable to index #{url} into searchgov:\n#{error}\n#{error.backtrace.first}"
      end
    end
    save!
  end

  private

  def validate_response(response)
    raise SearchgovUrlError.new(response.code) unless response.code == 200
    if PublicSuffix.domain(URI(url).host) != PublicSuffix.domain(response.uri.host)
      raise SearchgovUrlError.new("Redirection forbidden to #{response.uri}")
    end
  end

  def index_document(file)
    document = HtmlDocument.new(document: file, url: url)
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
end
