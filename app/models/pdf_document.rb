class PdfDocument < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20

  belongs_to :affiliate
  validates_presence_of :title, :url, :description, :affiliate_id
  validates_uniqueness_of :url, :message => "has already been added", :scope => :affiliate_id
  before_save :ensure_http_prefix_on_url

  searchable do
    text :title, :boost => 10.0
    text :description, :boost => 4.0
    text :keywords do
      keywords.split(',') unless keywords.nil?
    end
    integer :affiliate_id
  end
  
  def self.search_for(query, affiliate = nil, page = 1, per_page = 3)
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

  private
  
  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^http(s?)://}i
  end
end
