class IndexedDocument < ActiveRecord::Base
  class IndexedDocumentError < RuntimeError;
  end

  belongs_to :affiliate
  belongs_to :indexed_domain
  before_validation :normalize_url
  before_save :set_indexed_domain
  validates_presence_of :url, :affiliate_id
  validates_presence_of :title, :description, :if => :last_crawl_status_ok?
  validates_uniqueness_of :url, :message => "has already been added", :scope => :affiliate_id
  validates_uniqueness_of :content_hash, :message => "is not unique: Identical content (title and body) already indexed", :scope => :affiliate_id, :allow_nil => true
  validates_format_of :url, :with => /^https?:\/\/[a-z0-9]+([\-\.][a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/]\S*)?$/ix
  validates_length_of :url, :maximum => 2000
  validate :url_is_parseable
  validate :site_domain_matches
  validate :robots_txt_compliance
  validate :odie_candidacy

  OK_STATUS = "OK"
  scope :ok, where(:last_crawl_status => OK_STATUS)
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
  UNPARSEABLE_URL_STATUS = "URL format can't be parsed by USASearch software"
  ROBOTS_TXT_COMPLIANCE = "URL blocked by site's robots.txt file"
  ODIE_CANDIDACY = "URL must belong to a document collection or hosted sitemap unless you are using Odie results. Set up your collection or hosted sitemap first and then upload the URL."
  VALID_BULK_UPLOAD_CONTENT_TYPES = %w{text/plain txt}

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
    string :doctype
    integer :affiliate_id
    string :url
    time :created_at, :trie => true
  end

  def fetch
    site_domain_matches
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
              begin
                response.read_body { |chunk| file.write chunk }
                file.flush
                file.rewind
                index_document(file, response.content_type)
                self.content_hash = build_content_hash
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
      update_attributes!(:last_crawled_at => Time.now, :last_crawl_status => normalize_error_message(e), :content_hash => nil, :title => nil, :body => nil, :description => nil)
    rescue Exception
      begin
        destroy
      rescue Exception
        Rails.logger.warn 'IndexedDocument: Could not destroy record'
      end
    end
  end

  def save_or_destroy
    begin
      save!
    rescue Mysql2::Error
      destroy
    rescue ActiveRecord::RecordInvalid
      raise IndexedDocumentError.new(errors.full_messages.join.to_s)
    end
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
    title = doc.xpath("//title").first.content.squish.truncate(TRUNCATED_TITLE_LENGTH, :separator => " ") rescue nil
    doc.css('script').each(&:remove)
    doc.css('style').each(&:remove)
    body = extract_body_from(doc)
    raise IndexedDocumentError.new(EMPTY_BODY_STATUS) if body.blank?
    description = generate_generic_description(body)
    self.attributes = {:title => title, :description => description, :body => body, :doctype => 'html', :last_crawled_at => Time.now, :last_crawl_status => OK_STATUS}
    discover_nested_docs(doc)
  end

  def index_application_file(file_path, doctype)
    document_text = parse_file(file_path, 't').strip rescue nil
    raise IndexedDocumentError.new(EMPTY_BODY_STATUS) if document_text.blank?
    self.attributes = {:title => extract_document_title(file_path, document_text), :description => generate_generic_description(document_text),
                       :body => scrub_inner_text(document_text), :doctype => doctype, :last_crawled_at => Time.now, :last_crawl_status => OK_STATUS}
  end

  def generate_generic_description(text)
    text.gsub(/[^\w_]/, " ").gsub(/[“’‘”]/, "").gsub(/ /, "").squish.truncate(TRUNCATED_DESC_LENGTH, :separator => " ")
  end

  def extract_body_from(nokogiri_doc)
    remove_common_substrings(scrub_inner_text(Sanitize.clean(nokogiri_doc.at('body').inner_html))) rescue ''
  end

  def scrub_inner_text(inner_text)
    inner_text.gsub(/ /, ' ').squish.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ').gsub('&amp;', '&').squish
  end

  def remove_common_substrings(body)
    indexed_domain = IndexedDomain.find_by_domain(self_url.host)
    return body unless indexed_domain.present? and indexed_domain.common_substrings.present?
    escaped_substrings = indexed_domain.common_substrings.map { |common_substring| Regexp.escape(common_substring.substring) }
    substring_regex = ['(', escaped_substrings.join('|'), ')'].join
    body.gsub(/#{substring_regex}/, ' ').squish
  end

  def remove_common_substring(unescaped_substring)
    self.body = self.body.gsub(/#{Regexp.escape(unescaped_substring)}/, ' ').squish
    self.description = generate_generic_description(self.body)
    self.save
  end

  def body_for_substring_detection
    return nil if body.nil?
    body.size >= LARGE_DOCUMENT_THRESHOLD ? body.first(LARGE_DOCUMENT_SAMPLE_SIZE) + body.last(LARGE_DOCUMENT_SAMPLE_SIZE) : body
  end

  def discover_nested_docs(doc)
    doc.css('a').collect { |link| link['href'] }.compact.map do |link_url|
      URI.merge_unless_recursive(self_url, URI.parse(link_url)).to_s rescue nil
    end.uniq.compact.each do |link_url|
      affiliate.indexed_documents.create(:url => link_url) if link_url.present?
    end
  end

  def build_content_hash
    Digest::MD5.hexdigest((self.title || '') + self.body)
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

    def process_file(file, affiliate, max_urls = MAX_URLS_PER_FILE_UPLOAD)
      if file.blank? or !VALID_BULK_UPLOAD_CONTENT_TYPES.include?(file.content_type)
        return {:success => false, :error_message => 'Invalid file format; please upload a plain text file (.txt).'}
      end

      counter = 0
      if (max_urls == 0 or file.tempfile.lines.count <= max_urls) and file.tempfile.open
        file.tempfile.each { |line| counter += 1 if create(:url => line.chomp.strip, :affiliate => affiliate).errors.empty? }
        if counter > 0
          affiliate.refresh_indexed_documents('unfetched')
          {:success => true, :count => counter}
        else
          {:success => false, :error_message => 'No URLs uploaded; please check your file and try again.'}
        end
      else
        {:success => false, :error_message => "Too many URLs in your file.  Please limit your file to #{max_urls} URLs."}
      end
    end

    def refresh(extent)
      select("distinct affiliate_id").each { |result| Affiliate.find(result[:affiliate_id]).refresh_indexed_documents(extent) }
    end

    def bulk_load_urls(file_path)
      File.open(file_path).each do |line|
        affiliate_id, url = line.chomp.split("\t")
        create(:url => url, :affiliate_id => affiliate_id)
      end
      refresh('unfetched')
    end

  end

  def self_url
    @self_url ||= URI.parse(self.url) rescue nil
  end

  private

  def set_indexed_domain
    self.indexed_domain = IndexedDomain.find_or_create_by_affiliate_id_and_domain(self.affiliate.id, self_url.host) if last_crawl_status_ok?
  end

  def parse_file(file_path, option)
    %x[cat #{file_path} | java -Xmx512m -jar #{Rails.root.to_s}/vendor/jars/tika-app-1.1.jar -#{option}]
  end

  def extract_document_title(pdf_file_path, pdf_text)
    parse_file(pdf_file_path, 'm').scan(/title: (\w.*)/i)[0][0].squish
  rescue
    pdf_text.split(/[\n.]/).first.squish
  end

  def normalize_url
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

  def site_domain_matches
    uri = self_url rescue nil
    return if self.affiliate.nil? or uri.nil?
    errors.add(:base, DOMAIN_MISMATCH_STATUS) unless self.affiliate.site_domains.any? do |sd|
      if sd.domain.starts_with?('.')
        uri.host =~ /#{sd.domain}$/i
      else
        site_domain_url_fragment = sd.domain
        site_domain_url_fragment.strip!
        site_domain_url_fragment = "#{uri.scheme}://#{site_domain_url_fragment}" unless site_domain_url_fragment =~ %r{^https?://}i
        site_domain_url_fragment = "#{site_domain_url_fragment}/" unless site_domain_url_fragment.ends_with?("/")
        site_domain_uri = URI.parse(site_domain_url_fragment)
        uri.host =~ /#{site_domain_uri.host}/i and uri.path =~ /#{site_domain_uri.path}/i
      end
    end
  end

  def robots_txt_compliance
    if self_url
      if (robot = Robot.find_by_domain(self_url.host))
        if robot.disallows?(self_url.request_uri)
          errors.add(:base, ROBOTS_TXT_COMPLIANCE)
        end
      end
    end
  end

  def odie_candidacy
    return unless self.affiliate.present?
    errors.add(:base, ODIE_CANDIDACY) unless self.affiliate.uses_odie_results? or
      (self.affiliate.features & Feature.find_all_by_internal_name(%w{odie_api hosted_sitemaps})).present? or
      self.affiliate.url_prefixes.where("prefix like ?", url + "%").present?
  end

  def url_is_parseable
    URI.parse(self.url) rescue errors.add(:base, UNPARSEABLE_URL_STATUS)
  end

  def last_crawl_status_ok?
    last_crawl_status == OK_STATUS
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
