require 'filetype'

# coding: utf-8
class IndexedDocument < ApplicationRecord
  include Dupable
  include FastDeleteFromDbAndEs
  include Fetchable

  class IndexedDocumentError < RuntimeError;
  end

  belongs_to :affiliate

  validates_presence_of :affiliate_id, :title
  validates_uniqueness_of :url, :message => "has already been added", :scope => :affiliate_id, :case_sensitive => false
  validate :extension_ok

  SUMMARIZED_STATUS = 'summarized'
  NON_ERROR_STATUSES = [OK_STATUS, SUMMARIZED_STATUS]

  scope :summarized, -> { where(:last_crawl_status => SUMMARIZED_STATUS) }
  scope :html, -> { where(:doctype => 'html') }
  scope :by_matching_url, -> (substring) { where("url like ?","%#{substring}%") if substring.present? }

  MAX_DOC_SIZE = 50.megabytes
  DOWNLOAD_TIMEOUT_SECS = 300
  EMPTY_BODY_STATUS = "No content found in document"

  def fetch
    destroy and return unless errors.empty?
    begin
      uri = URI(url)
      Timeout.timeout(DOWNLOAD_TIMEOUT_SECS) do
        self.load_time = Benchmark.realtime do
          Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            request = Net::HTTP::Get.new uri.request_uri, {'User-Agent' => DEFAULT_USER_AGENT }
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
      update!(:last_crawled_at => Time.now, :last_crawl_status => normalize_error_message(e), :body => nil)
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
    self.attributes = { body: extract_body_from(doc), doctype: 'html', last_crawled_at: Time.now, last_crawl_status: OK_STATUS }
  end

  def index_application_file(file_path, doctype)
    document_text = begin
      parse_file(file_path).strip
    rescue
      nil
    end
    raise IndexedDocumentError, EMPTY_BODY_STATUS if document_text.blank?

    self.attributes = { body: scrub_inner_text(document_text), doctype: doctype, last_crawled_at: Time.zone.now, last_crawl_status: OK_STATUS }
  end

  def extract_body_from(nokogiri_doc)
    body = scrub_inner_text(Sanitizer.sanitize(nokogiri_doc.at('body').inner_html.encode('utf-8'))) rescue ''
    raise IndexedDocumentError.new(EMPTY_BODY_STATUS) if body.blank?
    body
  end

  def scrub_inner_text(inner_text)
    inner_text.gsub(/ /, ' ').squish.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ').gsub('&amp;', '&').squish
  end

  def last_crawl_status_error?
    !NON_ERROR_STATUSES.include?(last_crawl_status)
  end

  def source_manual?
    source == 'manual'
  end

  private

  def parse_file(file_path)
    Tika.get_recursive_metadata(File.open(file_path)).first['X-TIKA:content']
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

  def scheme
    self_url.scheme.downcase
  end
end
