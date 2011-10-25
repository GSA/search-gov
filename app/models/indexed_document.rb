require 'pdf/toolkit'

class IndexedDocument < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :title, :url, :description, :doctype, :affiliate_id, :locale
  validates_uniqueness_of :url, :message => "has already been added", :scope => :affiliate_id
  validate :doctype, :inclusion => {:in => %w(html pdf), :message => "must be either 'html' or 'pdf.'"}
  validate :locale, :inclusion => {:in => %w(en es), :message => "must be either 'en' or 'es.'"}
  before_save :ensure_http_prefix_on_url

  TRUNCATED_TITLE_LENGTH = 60
  TRUNCATED_DESC_LENGTH = 250


  searchable do
    text :title, :boost => 10.0
    text :description, :boost => 4.0
    text :body
    text :keywords do
      keywords.split(',') unless keywords.nil?
    end
    string :doctype
    string :locale
    integer :affiliate_id
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
          paginate :page => page, :per_page => per_page
        end rescue nil
      end
    end

    def fetch(url, affiliate_id)
      begin
        url.ends_with?(".pdf") ? fetch_pdf(url, affiliate_id) : fetch_html(url, affiliate_id)
      rescue Exception => e
        Rails.logger.error "Trouble fetching #{url} for indexed document creation: #{e}"
      end
    end

    def fetch_html(url, affiliate_id)
      doc = Nokogiri::HTML(open(url))
      return unless (title = doc.xpath("//title").first.content.squish.truncate(TRUNCATED_TITLE_LENGTH, :separator=>" ") rescue nil)
      description = doc.xpath("//meta[translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'description' ] ").first.attributes["content"].value.squish rescue nil
      if description.nil?
        doc.xpath('//script').each { |x| x.remove }
        doc.xpath('//style').each { |x| x.remove }
        description = doc.inner_text.strip.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ').truncate(TRUNCATED_DESC_LENGTH, :separator => ' ')
      end
      body = doc.inner_text.strip.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ')
      indexed_document = find_or_initialize_by_url_and_affiliate_id(url, affiliate_id)
      indexed_document.update_attributes(:title=> title, :description => description, :body => body, :doctype => 'html')
      indexed_document.save!
    end

    def fetch_pdf(url, affiliate_id)
      pdf = PDF::Toolkit.open(open(url))
      indexed_document = find_or_initialize_by_url_and_affiliate_id(url, affiliate_id)
      indexed_document.update_attributes(:title => generate_pdf_title(pdf, url), :description => generate_pdf_description(pdf.to_text.read), :body => pdf.to_text.read, :doctype => 'pdf')
      indexed_document.save!
    end

  end

  private

  class << self
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
  end

  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^http(s?)://}i
  end
end