require 'pdf/toolkit'

class IndexedDocument < ActiveRecord::Base
  class IndexedDocumentError < RuntimeError;
  end
  attr_reader :url_extension

  belongs_to :affiliate
  before_validation :normalize_url
  validates_presence_of :url, :affiliate_id
  validates_uniqueness_of :url, :message => "has already been added", :scope => :affiliate_id
  validates_uniqueness_of :content_hash, :message => "is not unique: Identical content (title and body) already indexed", :scope => :affiliate_id, :allow_nil => true
  validates_format_of :url, :with => /^http:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/]\S*)?$/ix
  validates_exclusion_of :url_extension, :in => %w(json xml rss csv css js png gif jpg jpeg txt ico wsdl htc swf), :message => "'%{value}' is not a supported file type"
  validates_inclusion_of :doctype, :in => %w(html pdf), :message => "must be either 'html' or 'pdf.'"
  validate :site_domain_matches

  TRUNCATED_TITLE_LENGTH = 60
  TRUNCATED_DESC_LENGTH = 250
  MAX_URLS_PER_FILE_UPLOAD = 100
  OK_STATUS = "OK"
  EMPTY_BODY_STATUS = "No content found in document"
  DOMAIN_MISMATCH_STATUS = "URL doesn't match affiliate's site domains"
  VALID_BULK_UPLOAD_CONTENT_TYPES = %w{text/plain txt}

  searchable do
    text :title, :boost => 10.0 do |idoc|
      idoc.title if idoc.affiliate.locale == "en"
    end
    text :title_es, :boost => 10.0, :as => "title_text_es" do |idoc|
      idoc.title if idoc.affiliate.locale == "es"
    end
    text :description, :boost => 4.0 do |idoc|
      idoc.description if idoc.affiliate.locale == "en"
    end
    text :description_es, :boost => 4.0, :as => "description_text_es" do |idoc|
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
  end

  def fetch
    site_domain_matches
    delete and return unless errors.empty?
    begin
      file = open(url)
      content_type = file.content_type
      if file.is_a?(StringIO)
        tempfile = Tempfile.new(Time.now.to_i)
        tempfile.write(file.string)
        tempfile.close
        file = tempfile
      end
      index_document(file, content_type)
      update_content_hash
    rescue Exception => e
      update_attributes!(:last_crawled_at => Time.now, :last_crawl_status => e.message, :content_hash => nil)
    ensure
      File.delete(file) unless file.nil?
    end
  end

  def index_document(file, content_type)
    if content_type =~ /pdf/
      index_pdf(file.path)
    elsif content_type =~ /html/
      index_html(file)
    else
      raise IndexedDocumentError.new "Unsupported document type: #{file.content_type}"
    end
  end

  def index_html(file)
    file.open if file.closed?
    doc = Nokogiri::HTML(file)
    title = doc.xpath("//title").first.content.squish.truncate(TRUNCATED_TITLE_LENGTH, :separator => " ") rescue nil
    description = doc.xpath("//meta[translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'description' ] ").first.attributes["content"].value.squish rescue nil
    doc.xpath('//script').each { |x| x.remove }
    doc.xpath('//style').each { |x| x.remove }
    body = scrub_inner_text(doc.inner_text)
    raise IndexedDocumentError.new(EMPTY_BODY_STATUS) if body.blank?
    description ||= body.gsub(/ /, "").gsub(/\.{2,}/, ".").squish.truncate(TRUNCATED_DESC_LENGTH, :separator => ' ')
    update_attributes!(:title=> title, :description => description, :body => body, :doctype => 'html', :last_crawled_at => Time.now, :last_crawl_status => OK_STATUS)
    discover_nested_pdfs(doc)
  end

  def discover_nested_pdfs(doc)
    doc.css('a').collect { |link| link['href'] }.compact.select do |link_url|
      link_url.ends_with(".pdf")
    end.map do |relative_pdf_url|
      URI.parse(self.url).merge(URI.parse(relative_pdf_url)).to_s
    end.uniq.each do |pdf_url|
      IndexedDocument.create(:affiliate_id => self.affiliate.id, :url => pdf_url)
    end
  end

  def scrub_inner_text(inner_text)
    inner_text.strip.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ')
  end

  def index_pdf(pdf_file_path)
    pdf_text = PDF::Toolkit.pdftotext(pdf_file_path) { |io| io.read }
    raise IndexedDocumentError.new(EMPTY_BODY_STATUS) if pdf_text.blank?
    update_attributes!(:title => generate_pdf_title(pdf_file_path), :description => generate_pdf_description(pdf_text), :body => pdf_text, :doctype => 'pdf', :last_crawled_at => Time.now, :last_crawl_status => OK_STATUS)
  end

  def update_content_hash
    begin
      self.content_hash = build_content_hash
      save!
    rescue ActiveRecord::RecordInvalid
      raise IndexedDocumentError.new(errors.full_messages.to_s)
    end
  end

  def build_content_hash
    Digest::MD5.hexdigest((self.title || '') + self.body)
  end

  class << self
    def search_for(query, affiliate, page = 1, per_page = 3)
      return if affiliate.nil? or query.blank?
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => {:model=> self.name, :term => query, :affiliate => affiliate.name}) do
        search do
          fulltext query do
            highlight :title, :description, :title_es, :description_es, :max_snippets => 1, :fragment_size => 255, :merge_continuous_fragments => true
          end
          with(:affiliate_id, affiliate.id)
          without(:url).any_of affiliate.excluded_urls.collect { |excluded_url| excluded_url.url } unless affiliate.excluded_urls.empty?
          with(:last_crawl_status, OK_STATUS)
          paginate :page => page, :per_page => per_page
        end rescue nil
      end
    end

    def uncrawled_urls(affiliate, page = 1, per_page = 30)
      paginate(:conditions => ['affiliate_id = ? AND ISNULL(last_crawled_at)', affiliate.id], :page => page, :order => 'id DESC', :per_page => per_page)
    end

    def crawled_urls(affiliate, page = 1, per_page = 30)
      paginate(:conditions => ['affiliate_id = ? AND NOT ISNULL(last_crawled_at)', affiliate.id], :page => page, :order => 'last_crawled_at desc, id desc', :per_page => per_page)
    end

    def process_file(file, affiliate, max_urls = MAX_URLS_PER_FILE_UPLOAD)
      if file.blank? or !VALID_BULK_UPLOAD_CONTENT_TYPES.include?(file.content_type)
        return { :success => false, :error_message => 'Invalid file format; please upload a plain text file (.txt).'}
      end

      counter = 0
      if file.tempfile.lines.count <= max_urls and file.tempfile.open
        file.tempfile.each { |line| counter += 1 if create(:url => line.chomp.strip, :affiliate => affiliate).errors.empty? }
        counter > 0 ?  { :success => true, :count => counter } : { :success => false, :error_message => 'No URLs uploaded; please check your file and try again.' }
      else
        { :success => false, :error_message => "Too many URLs in your file.  Please limit your file to #{max_urls} URLs." }
      end
    end

    def refresh_all
      all(:select=>:id).each { |indexed_document_fragment| Resque.enqueue(IndexedDocumentFetcher, indexed_document_fragment.id) }
    end

    def bulk_load_urls(file_path)
      File.open(file_path).each do |line|
        affiliate_id, url = line.chomp.split("\t")
        create(:url => url, :affiliate_id => affiliate_id)
      end
    end

  end

  private

  def url_extension
    URI::parse(url).path.split('.').last rescue nil
  end

  def generate_pdf_title(pdf_file_path)
    pdf = PDF::Toolkit.open(pdf_file_path) rescue nil
    return pdf.title unless pdf.nil? or pdf.title.blank?
    body = pdf.to_text.read
    first_linebreak_index = body.strip.index("\n") || body.size
    first_sentence_index = body.strip.index(".")
    end_index = [first_linebreak_index, first_sentence_index].min - 1
    body[0..end_index].strip
  end

  def generate_pdf_description(pdf_text)
    pdf_text.squish.gsub(/[^\w_ ]/, "").gsub(/[“’‘”]/, "").gsub(/ /, "").squish.truncate(TRUNCATED_DESC_LENGTH, :separator => " ")
  end

  def normalize_url
    ensure_http_prefix_on_url
    remove_anchor_tags_from_url
  end

  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^http://}i
  end

  def remove_anchor_tags_from_url
    self.url.sub!(/#.*$/, '') unless self.url.blank?
  end

  def site_domain_matches
    uri = URI.parse(self.url) rescue nil
    return if self.affiliate.nil? or self.affiliate.site_domains.empty? or uri.nil?
    host_path = (uri.host + uri.path).downcase
    errors.add(:base, DOMAIN_MISMATCH_STATUS) unless self.affiliate.site_domains.any? { |sd| host_path.include?(sd.domain) }
  end
end
