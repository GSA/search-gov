class SearchgovUrl < ActiveRecord::Base
  include Fetchable
  include RobotsTaggable
  include ActionView::Helpers::NumberHelper

  MAX_DOC_SIZE = 10.megabytes
  SUPPORTED_CONTENT_TYPES = %w(
                                text/html
                                application/msword
                                application/pdf
                                application/vnd.ms-excel
                                application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                              )

  attr_accessible :last_crawl_status, :last_crawled_at, :url
  attr_reader :response, :document

  validate :unique_link
  validates :url_extension,
    exclusion: { in: BLACKLISTED_EXTENSIONS,  message: "is not one we index" },
    allow_blank: true

  before_validation :escape_url
  before_destroy :delete_document

  class SearchgovUrlError < StandardError; end

  def fetch
    self.last_crawled_at = Time.now
    self.load_time = Benchmark.realtime do
      DocumentFetchLogger.new(url, 'searchgov_url').log
      begin
        @response = get_response

        validate_response
        validate_content_type

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

  def document_id
    Digest::SHA256.hexdigest(url_without_protocol)
  end

  private

  def get_response
    HTTP.headers(user_agent: DEFAULT_USER_AGENT).follow.get(url)
  rescue HTTP::Redirector::TooManyRedirectsError
    # https://github.com/httprb/http/issues/264
    Rails.logger.error "Fetch failed for #{url}. Retrying with cookies..."
    response = HTTP.get(url)
    HTTP.cookies(response.cookies).follow.get(url)
  end

  def download
    file = Tempfile.open("SearchgovUrl:#{Time.now.to_i}", Rails.root.join('tmp'))
    file.binmode
    body = response.body
    file.write body.readpartial until (file.write body.readpartial) == 0
    file
  end

  def validate_response
    raise SearchgovUrlError.new(response.code) unless response.code == 200
    validate_size
    raise SearchgovUrlError.new("Redirection forbidden to #{response.uri}") if redirected_outside_domain?
    raise SearchgovUrlError.new('Noindex per X-Robots-Tag header') if noindex?
  end

  def validate_content_type
    content_type = response.content_type.mime_type
    unless SUPPORTED_CONTENT_TYPES.include?(content_type)
      raise SearchgovUrlError.new("Unsupported content type '#{content_type}'")
    end
  end

  def validate_document
    raise SearchgovUrlError.new(404) if /page not found|404 error/i === document.title
    raise SearchgovUrlError.new('Noindex per HTML metadata') if document.noindex?
  end

  def validate_size
    size = response.headers['Content-Length']
    if size.present? && size.to_i > MAX_DOC_SIZE
      raise SearchgovUrlError.new("Document is over #{number_to_human_size(MAX_DOC_SIZE)} limit")
    end
  end

  def log_data
    {
      url: url,
      domain: URI.parse(url).host,
      orig_size: response.headers['Content-Length'],
      parsed_size: document.parsed_content&.bytesize,
      time: Time.now.utc.to_formatted_s(:db),
    }.to_json
  end

  def index_document
    Rails.logger.info "[Index SearchgovUrl] #{log_data}"
    I14yDocument.create(
                         document_id: document_id,
                         handle: 'searchgov',
                         path: url,
                         title: document.title,
                         content: document.parsed_content,
                         description: document.description,
                         language: document.language,
                         tags: document.keywords,
                         created: document.created,
                       )
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
    Rails.logger.info "Parsing document for #{url}"
    if /^application/ === response.content_type.mime_type
      ApplicationDocument.new(document: download.open, url: url)
    else
      HtmlDocument.new(document: response.to_s, url: url)
    end
  end

  def redirected_outside_domain?
    PublicSuffix.domain(URI(url).host) != PublicSuffix.domain(response.uri.host)
  end

  def robots_directives
    headers = response.headers.to_hash
    RobotsTagParser.get_rules(headers: headers, user_agent: DEFAULT_USER_AGENT)
  end

  def escape_url
    self.url = Addressable::URI.normalized_encode(url) rescue ''
  end

  def delete_document
    I14yDocument.delete(handle: 'searchgov', document_id: document_id)
  rescue I14yDocument::I14yDocumentError => e
    Rails.logger.error "Unable to delete Searchgov i14y document #{document_id}: #{e.message}"
  end
end
