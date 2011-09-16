require 'pdf/toolkit'

class PdfDocument < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :title, :url, :description, :affiliate_id
  validates_uniqueness_of :url, :message => "has already been added", :scope => :affiliate_id
  before_save :ensure_http_prefix_on_url

  searchable do
    text :title, :boost => 10.0
    text :description, :boost => 4.0
    text :body
    text :keywords do
      keywords.split(',') unless keywords.nil?
    end
    integer :affiliate_id
  end
  
  class << self
    def search_for(query, affiliate = nil, page = 1, per_page = 3)
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => {:model=> self.name, :term => query, :affiliate => affiliate.name}) do
        search do
          fulltext query do
            highlight :title, :description, :max_snippets => 1, :fragment_size => 255, :merge_continuous_fragments => true
          end
          with(:affiliate_id, affiliate.id)
          paginate :page => page, :per_page => per_page
        end rescue nil
      end
    end

    def crawl_pdf(url)
      begin
        pdf_io = open(url)
        pdf = PDF::Toolkit.open(pdf_io)
        PdfDocument.new(:url => url, :title => generate_title(pdf, url), :description => generate_description(pdf.to_text.read), :body => pdf.to_text.read)
      rescue Exception => e
        Rails.logger.error "Trouble fetching #{url} for boosted content creation: #{e}"
      end
    end
  
    def is_pdf?(url)
      url.ends_with(".pdf").present?
    end
  end

  private
  
  class << self
    def generate_title(pdf, url)
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
    
    def generate_description(body)
      body.truncate(500, :separator => " ")
    end
  end

  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^http(s?)://}i
  end
end
