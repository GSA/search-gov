require 'pdf/toolkit'

class IndexedDocument < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :url, :affiliate_id
  validates_uniqueness_of :url, :message => "has already been added", :scope => :affiliate_id
  validates_format_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
  validate :doctype, :inclusion => {:in => %w(html pdf), :message => "must be either 'html' or 'pdf.'"}
  validate :locale, :inclusion => {:in => %w(en es), :message => "must be either 'en' or 'es.'"}
  before_validation :ensure_http_prefix_on_url

  TRUNCATED_TITLE_LENGTH = 60
  TRUNCATED_DESC_LENGTH = 250
  MAX_URLS_PER_FILE_UPLOAD = 100
  OK_STATUS = "OK"

  searchable do
    text :title, :boost => 10.0
    text :description, :boost => 4.0
    text :body
    string :last_crawl_status
    string :doctype
    string :locale
    integer :affiliate_id
  end

  def fetch
    begin
      file = open(url)
      if file.is_a?(StringIO)
        tempfile = Tempfile.new(Time.now.to_s)
        tempfile.write(file.string)
        tempfile.close
        file = tempfile
      end
      url.ends_with?(".pdf") ? index_pdf(file.path) : index_html(file)
    rescue Exception => e
      Rails.logger.error "Trouble fetching #{url} to index: #{e}"
      update_attributes!(:last_crawled_at => Time.now, :last_crawl_status => e.message)
    ensure
      File.delete(file) unless file.nil?
    end
  end

  def index_html(file)
    doc = Nokogiri::HTML(file)
    title = doc.xpath("//title").first.content.squish.truncate(TRUNCATED_TITLE_LENGTH, :separator => " ") rescue nil
    description = doc.xpath("//meta[translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'description' ] ").first.attributes["content"].value.squish rescue nil
    if description.nil?
      doc.xpath('//script').each { |x| x.remove }
      doc.xpath('//style').each { |x| x.remove }
      description = doc.inner_text.strip.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ').truncate(TRUNCATED_DESC_LENGTH, :separator => ' ')
    end
    body = doc.inner_text.strip.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ')
    update_attributes!(:title=> title, :description => description, :body => body, :doctype => 'html', :last_crawled_at => Time.now, :last_crawl_status => OK_STATUS)
  end

  def index_pdf(file)
    pdf = PDF::Toolkit.open(file)
    update_attributes!(:title => generate_pdf_title(pdf, self.url), :description => generate_pdf_description(pdf.to_text.read), :body => pdf.to_text.read, :doctype => 'pdf', :last_crawled_at => Time.now, :last_crawl_status => OK_STATUS)
  end

  class << self
    def search_for(query, affiliate = nil, locale = I18n.default_locale.to_s, page = 1, per_page = 3)
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => {:model=> self.name, :term => query, :affiliate => affiliate.name}) do
        search do
          fulltext query do
            highlight :title, :description, :max_snippets => 1, :fragment_size => 255, :merge_continuous_fragments => true
          end
          with(:affiliate_id, affiliate.id)
          with(:locale, locale)
          with(:last_crawl_status, OK_STATUS)
          paginate :page => page, :per_page => per_page
        end rescue nil
      end
    end

    def uncrawled_urls(affiliate, number_of_urls = nil)
      sql_options = {:order => 'created_at asc'}
      sql_options.merge!(:limit => number_of_urls) if number_of_urls
      find_all_by_last_crawled_at_and_affiliate_id(nil, affiliate.id, sql_options)
    end

    def crawled_urls(affiliate, page = 1)
      paginate(:conditions => ['affiliate_id = ? AND NOT ISNULL(last_crawled_at)', affiliate.id], :page => page, :order => 'last_crawled_at desc')
    end

    def process_file(file, affiliate, max_urls = MAX_URLS_PER_FILE_UPLOAD)
      counter = 0
      if file.tempfile.lines.count <= max_urls and file.tempfile.open
        file.tempfile.each { |line| counter += 1 if create(:url => line.chomp.strip, :affiliate => affiliate).errors.empty? }
        return counter
      else
        raise "Too many URLs in your file.  Please limit your file to #{max_urls} URLs."
      end
    end

    def refresh_all
      all(:select=>:id).each { |indexed_document_fragment| Resque.enqueue(IndexedDocumentFetcher, indexed_document_fragment.id) }
    end
  end

  private

  def generate_pdf_title(pdf, url)
    return pdf.title unless pdf.title.blank?
    begin
      body = pdf.to_text.read
      first_linebreak_index = body.strip.index("\n") || body.size
      first_sentence_index = body.strip.index(".")
      end_index = [first_linebreak_index, first_sentence_index].min - 1
      return body.strip[0..end_index]
    rescue
      return URI.decode(url[url.rindex("/") + 1..-1])
    end
  end

  def generate_pdf_description(body)
    body.truncate(500, :separator => " ")
  end

  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^http(s?)://}i
  end
end