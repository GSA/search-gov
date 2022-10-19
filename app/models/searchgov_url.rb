# frozen_string_literal: true

class SearchgovUrl < ApplicationRecord
  include Fetchable
  include RobotsTaggable
  include ActionView::Helpers::NumberHelper

  MAX_DOC_SIZE = 15.megabytes
  SUPPORTED_CONTENT_TYPES = %w[
                                text/html
                                text/plain
                                application/msword
                                application/pdf
                                application/vnd.ms-excel
                                application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                              ]

  attr_reader :response, :document, :tempfile
  attr_readonly :url

  validates_associated :searchgov_domain, on: :create
  validates(:searchgov_domain,
            presence: { message: 'is not a valid SearchgovDomain' },
            on: :create
            )

  validates :url, uniqueness: true
  validates :url_extension,
    exclusion: { in: BLACKLISTED_EXTENSIONS,  message: "is not one we index" },
    allow_blank: true

  before_validation :set_searchgov_domain, on: :create
  before_destroy :delete_document

  belongs_to :searchgov_domain
  counter_culture :searchgov_domain, column_name: 'urls_count', execute_after_commit: true
  counter_culture :searchgov_domain,
                  column_name: proc {|url| !url.fetched? ? 'unfetched_urls_count' : nil },
                  column_names: { ['searchgov_urls.last_crawled_at IS NULL'] => 'unfetched_urls_count' },
                  execute_after_commit: true

  has_one :searchgov_document, dependent: :destroy

  scope :fetch_required, -> do
    where('last_crawled_at IS NULL
           OR lastmod > last_crawled_at
           OR enqueued_for_reindex
           OR (last_crawl_status = "OK" AND last_crawled_at < ?)', 1.month.ago).
           order(last_crawled_at: :ASC)
  end

  class SearchgovUrlError < StandardError; end
  class DomainError < StandardError; end

  def fetch
    raise DomainError.new("#{searchgov_domain.domain}: #{searchgov_domain.status}") if !searchgov_domain.available?
    update(last_crawled_at: Time.now, enqueued_for_reindex: false)
    self.load_time = Benchmark.realtime do
      DocumentFetchLogger.new(url, 'searchgov_url').log
      begin
        @response = get_response

        validate_response
        validate_content_type

        @document = parse_document
        validate_document
        # SRCH-3134 Temporarily adding save/no save logic until we have documented how this functionality
        # behaves in production setting.
        save_document if ENV['SAVE_SEARCHGOV_DOCUMENT'] == 'true'
        index_document

        self.last_crawl_status = OK_STATUS
      rescue => error
        delete_document if indexed? && searchgov_domain.available?
        self.last_crawl_status = error.message.first(255)
        error_line = error.backtrace.find{ |line| line.starts_with?(Rails.root.to_s) }
        Rails.logger.error "[SearchgovUrl] Unable to index #{url} into searchgov: '#{error.class}: #{error}'. Called from: #{error_line}".red
      ensure
        tempfile&.close!
      end
    end
    save!
  end

  def document_id
    Digest::SHA256.hexdigest(url_without_protocol)
  end

  private

  def get_response
    client = HTTP.headers(user_agent: DEFAULT_USER_AGENT).timeout(connect: 20, read: 60)
    client.follow.get(url)
  rescue HTTP::Redirector::TooManyRedirectsError
    # https://github.com/httprb/http/issues/264
    Rails.logger.error "[SearchgovUrl] Fetch failed for #{url}. Retrying with cookies...".red
    response = client.get(url)
    client.cookies(response.cookies).follow.get(url)
  rescue
    searchgov_domain.check_status
    raise
  end

  def download
    @tempfile ||= begin
      file = Tempfile.open("SearchgovUrl:#{Time.now.to_i}", Rails.root.join('tmp'))
      file.binmode
      body = response.body
      file.write body.readpartial until (file.write body.readpartial) == 0
      file
    end
  end

  def validate_response
    searchgov_domain.check_status if response.code == 403
    handle_redirection(response.uri.to_s) if self.url != response.uri.to_s
    raise SearchgovUrlError.new(response.code) unless response.code == 200
    validate_size
    raise SearchgovUrlError.new('Noindex per X-Robots-Tag header') if noindex?
  end

  def handle_redirection(new_url)
    raise SearchgovUrlError.new("Redirection forbidden to #{new_url}") if redirected_outside_domain?(new_url)
    SearchgovUrl.create(url: new_url)
    raise SearchgovUrlError.new("Redirected to #{new_url}")
  end

  def validate_content_type
    content_type = response.content_type.mime_type
    unless SUPPORTED_CONTENT_TYPES.include?(content_type)
      raise SearchgovUrlError.new("Unsupported content type '#{content_type}'")
    end
  end

  def validate_document
    handle_redirection(document.redirect_url) if document.redirect_url
    raise SearchgovUrlError.new(404) if /page not found|404 error/i === document.title
    raise SearchgovUrlError.new('Noindex per HTML metadata') if document.noindex?
  end

  def save_document
    doc = searchgov_document || build_searchgov_document

    return if skip_save?(doc)

    if application_document?
      doc.update(web_document: @document.metadata,
                 headers: response.headers.to_hash.transform_keys(&:downcase),
                 tika_version: Tika.tika_version)
    else
      doc.update(web_document: @document.document,
                 headers: response.headers.to_hash.transform_keys(&:downcase))
    end
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
    indexed? ? I14yDocument.update(i14y_params) : I14yDocument.create(i14y_params)
  end

  def i14y_params
    {
      audience: document.audience,
      changed: [lastmod, document.changed].compact.max&.iso8601,
      content: document.parsed_content,
      content_type: document.content_type,
      created: document.created&.iso8601,
      description: document.description,
      document_id: document_id,
      handle: 'searchgov',
      language: document.language,
      mime_type: response.content_type.mime_type,
      path: url,
      searchgov_custom1: document.searchgov_custom(1),
      searchgov_custom2: document.searchgov_custom(2),
      searchgov_custom3: document.searchgov_custom(3),
      tags: document.keywords,
      title: document.title
    }
  end

  def url_without_protocol
    UrlParser.strip_http_protocols(url)
  end

  def parse_document
    Rails.logger.info "[SearchgovUrl] Parsing document for #{url}"
    if application_document?
      ApplicationDocument.new(document: download.open, url: url)
    else
      parse_html_document
    end
  end

  def parse_html_document
    if searchgov_domain.js_renderer
      js_response = JsFetcher.fetch(url)
      HtmlDocument.new(document: js_response, url: url)
    else
      HtmlDocument.new(document: response.to_s, url: url)
    end
  end

  def skip_save?(doc)
    if application_document?
      # If an application document, skip if that document's entity tag is unchanged and if
      # the document was parsed with our current Tika version
      (doc&.etag == response.headers[:etag]) && (doc&.tika_version == Tika.tika_version)
    else
      # If not an application document, skip if that document's entity tag is unchanged
      doc&.etag == response.headers[:etag]
    end
  end

  def application_document?
    %r{^application|text/plain}.match?(response.content_type.mime_type)
  end

  def redirected_outside_domain?(new_url)
    URI(url).host != URI(new_url).host
  end

  def robots_directives
    headers = response.headers.to_hash
    RobotsTagParser.get_rules(headers: headers, user_agent: DEFAULT_USER_AGENT)
  end

  def delete_document
    I14yDocument.delete(handle: 'searchgov', document_id: document_id)
  rescue I14yDocument::I14yDocumentError => e
    Rails.logger.error "[SearchgovUrl] Unable to delete Searchgov i14y document #{document_id}: #{e.message}".red
  end
end
