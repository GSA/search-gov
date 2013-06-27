# coding: utf-8
class IndexedDocument < ActiveRecord::Base
  class IndexedDocumentError < RuntimeError;
  end

  belongs_to :affiliate
  before_validation :normalize_url
  validates_presence_of :url, :affiliate_id, :title, :description
  validates_uniqueness_of :url, :message => "has already been added", :scope => :affiliate_id, :case_sensitive => false
  validates_format_of :url, :with => /^https?:\/\/[a-z0-9]+([\-\.][a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/]\S*)?$/ix
  validates_length_of :url, :maximum => 2000
  validate :url_is_parseable
  validate :extension_ok

  OK_STATUS = "OK"
  SUMMARIZED_STATUS = 'summarized'
  scope :ok, where(:last_crawl_status => OK_STATUS)
  scope :summarized, where(:last_crawl_status => SUMMARIZED_STATUS)
  scope :not_ok, where("last_crawl_status <> '#{OK_STATUS}' OR ISNULL(last_crawled_at)")
  scope :fetched, where('last_crawled_at IS NOT NULL')
  scope :unfetched, where('ISNULL(last_crawled_at)')
  scope :html, where(:doctype => 'html')

  TRUNCATED_TITLE_LENGTH = 60
  TRUNCATED_DESC_LENGTH = 64000
  LARGE_DOCUMENT_SAMPLE_SIZE = 7500
  LARGE_DOCUMENT_THRESHOLD = 3 * LARGE_DOCUMENT_SAMPLE_SIZE
  MAX_URLS_PER_FILE_UPLOAD = 10000
  MAX_DOC_SIZE = 50.megabytes
  MAX_PDFS_DISCOVERED_PER_HTML_PAGE = 1000
  DOWNLOAD_TIMEOUT_SECS = 300
  EMPTY_BODY_STATUS = "No content found in document"
  DOMAIN_MISMATCH_STATUS = "URL doesn't match affiliate's site domains"
  DOMAIN_EXCLUDED_STATUS = "URL matches affiliate's excluded site domains"
  UNPARSEABLE_URL_STATUS = "URL format can't be parsed by USASearch software"
  UNSUPPORTED_EXTENSION = "URL extension is not one we index"
  VALID_BULK_UPLOAD_CONTENT_TYPES = %w{text/plain txt}
  BLACKLISTED_EXTENSIONS = %w{wmv mov css csv gif htc ico jpeg jpg js json mp3 png rss swf txt wsdl xml zip gz z bz2 tgz jar tar m4v}

  searchable do
    text :title, :stored => true, :boost => 10.0 do |idoc|
      idoc.title if idoc.affiliate.locale == "en"
    end
    text :title_es, :stored => true, :boost => 10.0, :as => "title_text_es" do |idoc|
      idoc.title if idoc.affiliate.locale == "es"
    end
    text :description, :stored => true, :boost => 4.0 do |idoc|
      idoc.description if idoc.affiliate.locale == "en"
    end
    text :description_es, :stored => true, :boost => 4.0, :as => "description_text_es" do |idoc|
      idoc.description if idoc.affiliate.locale == "es"
    end
    text :body do |idoc|
      idoc.body if idoc.affiliate.locale == "en"
    end
    text :body_es, :as => "body_text_es" do |idoc|
      idoc.body if idoc.affiliate.locale == "es"
    end
    string :last_crawl_status
    string :source
    string :doctype
    integer :affiliate_id
    string :url
    time :created_at, :trie => true
  end

  def fetch
    destroy and return unless errors.empty?
    begin
      uri = URI(url)
      timeout(DOWNLOAD_TIMEOUT_SECS) do
        self.load_time = Benchmark.realtime do
          Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            request = Net::HTTP::Get.new uri.request_uri, {'User-Agent' => 'usasearch'}
            http.request(request) do |response|
              raise IndexedDocumentError.new("#{response.code} #{response.message}") unless response.kind_of?(Net::HTTPSuccess)
              file = Tempfile.open("IndexedDocument:#{id}", Rails.root.join('tmp'))
              file.set_encoding Encoding::BINARY
              begin
                response.read_body { |chunk| file.write chunk }
                file.flush
                file.rewind
                index_document(file, response.content_type)
              ensure
                file.close
                file.unlink
              end
            end
          end
        end
        save_or_destroy
      end
    rescue Exception => e
      handle_fetch_exception(e)
    end
  end

  def handle_fetch_exception(e)
    begin
      update_attributes!(:last_crawled_at => Time.now, :last_crawl_status => normalize_error_message(e), :title => nil, :body => nil, :description => nil)
    rescue Exception
      begin
        destroy
      rescue Exception
        Rails.logger.warn 'IndexedDocument: Could not destroy record'
      end
    end
  end

  def save_or_destroy
    save!
  rescue Mysql2::Error
    destroy
  rescue ActiveRecord::RecordInvalid
    raise IndexedDocumentError.new("Problem saving indexed document: record invalid")
  end

  def index_document(file, content_type)
    raise IndexedDocumentError.new "Document is over #{MAX_DOC_SIZE/1.megabyte}mb limit" if file.size > MAX_DOC_SIZE
    case content_type
      when /html/
        index_html(file)
      when /pdf/
        index_application_file(file.path, 'pdf')
      when /(ms-excel|spreadsheetml)/
        index_application_file(file.path, 'excel')
      when /(ms-powerpoint|presentationml)/
        index_application_file(file.path, 'ppt')
      when /(ms-?word|wordprocessingml)/
        index_application_file(file.path, 'word')
      else
        raise IndexedDocumentError.new "Unsupported document type: #{file.content_type}"
    end
  end

  def index_html(file)
    doc = Nokogiri::HTML(file)
    doc.css('script').each(&:remove)
    doc.css('style').each(&:remove)
    body = extract_body_from(doc)
    raise IndexedDocumentError.new(EMPTY_BODY_STATUS) if body.blank?
    self.attributes = {:body => body, :doctype => 'html',
                       :last_crawled_at => Time.now, :last_crawl_status => OK_STATUS}
  end

  def index_application_file(file_path, doctype)
    document_text = parse_file(file_path, 't').strip rescue nil
    raise IndexedDocumentError.new(EMPTY_BODY_STATUS) if document_text.blank?
    self.attributes = {:body => scrub_inner_text(document_text), :doctype => doctype, :last_crawled_at => Time.now, :last_crawl_status => OK_STATUS}
  end

  def extract_body_from(nokogiri_doc)
    scrub_inner_text(Sanitize.clean(nokogiri_doc.at('body').inner_html.encode('utf-8'))) rescue ''
  end

  def scrub_inner_text(inner_text)
    inner_text.gsub(/ /, ' ').squish.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ').gsub('&amp;', '&').squish
  end

  class << self
    include QueryPreprocessor

    def search_for(query, affiliate, document_collection, page = 1, per_page = 3, created_at = nil)
      sanitized_query = preprocess(query)
      return if affiliate.nil? or sanitized_query.blank?
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => {:model => self.name, :term => sanitized_query, :affiliate => affiliate.name, :collection => (document_collection.name if document_collection.present?)}) do
        search do
          fulltext sanitized_query do
            highlight :title, :title_es, :frag_list_builder => 'single'
            highlight :description, :description_es, :fragment_size => 255
          end
          with(:affiliate_id, affiliate.id)
          any_of do
            document_collection.url_prefixes.each { |url_prefix| with(:url).starting_with(url_prefix.prefix) }
          end unless document_collection.nil?
          without(:url).any_of affiliate.excluded_urls.collect { |excluded_url| excluded_url.url } unless affiliate.excluded_urls.empty?
          with(:last_crawl_status, OK_STATUS)
          with(:created_at).greater_than(created_at) if created_at.present?
          paginate :page => page, :per_page => per_page
        end
      end
    rescue RSolr::Error::Http => e
      Rails.logger.warn "Error IndexedDocument#search_for: #{e.to_s}"
      nil
    end

    def uncrawled_urls(affiliate, page = 1, per_page = 30)
      where(['affiliate_id = ? AND last_crawled_at IS NULL', affiliate.id]).paginate(:page => page, :per_page => per_page)
    end

    def crawled_urls(affiliate, page = 1, per_page = 30)
      where(['affiliate_id = ? AND NOT ISNULL(last_crawled_at)', affiliate.id]).paginate(:page => page, :per_page => per_page).order('last_crawled_at desc, id desc')
    end

    def refresh(extent)
      select("distinct affiliate_id").each { |result| Affiliate.find(result[:affiliate_id]).refresh_indexed_documents(extent) rescue nil }
    end

  end

  def self_url
    @self_url ||= URI.parse(self.url) rescue nil
  end

  private

  def parse_file(file_path, option)
    %x[cat #{file_path} | java -Xmx512m -jar #{Rails.root.to_s}/vendor/jars/tika-app-1.3.jar -#{option}]
  end

  def normalize_url
    return if self.url.blank?
    ensure_http_prefix_on_url
    downcase_scheme_and_host_and_remove_anchor_tags
  end

  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^https?://}i
    @self_url = nil
  end

  def downcase_scheme_and_host_and_remove_anchor_tags
    if self_url
      scheme = self_url.scheme.downcase
      host = self_url.host.downcase
      request = self_url.request_uri.gsub(/\/+/, '/')
      self.url = "#{scheme}://#{host}#{request}"
      @self_url = nil
    end
  end

  def url_is_parseable
    URI.parse(self.url) rescue errors.add(:base, UNPARSEABLE_URL_STATUS)
  end

  def extension_ok
    path = URI.parse(self.url).path rescue ""
    extension = File.extname(path).sub(".", "").downcase
    errors.add(:base, UNSUPPORTED_EXTENSION) if BLACKLISTED_EXTENSIONS.include?(extension)
  end

  def normalize_error_message(e)
    case
      when e.message.starts_with?('redirection forbidden')
        'Redirection forbidden from HTTP to HTTPS'
      when e.message.starts_with?('Mysql2::Error: Duplicate entry')
        'Content hash is not unique: Identical content (title and body) already indexed'
      when e.message.include?('execution expired')
        'Document took too long to fetch'
      else
        e.message
    end
  end

end
