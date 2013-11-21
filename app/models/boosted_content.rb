class BoostedContent < ActiveRecord::Base
  include ActiveRecordExtension
  include BestBet

  cattr_reader :per_page
  @@per_page = 20

  belongs_to :affiliate
  has_many :boosted_content_keywords, dependent: :destroy, order: 'value'
  accepts_nested_attributes_for :boosted_content_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }

  validates :affiliate, :presence => true
  validates_presence_of :title, :url, :description, :publish_start_on
  validates_uniqueness_of :url, :message => "has already been boosted", :scope => "affiliate_id", :case_sensitive => false
  before_save :ensure_http_prefix_on_url

  scope :recent, { :order => 'updated_at DESC, id DESC', :limit => 5 }
  scope :substring_match, -> substring do
    select('DISTINCT boosted_contents.*').
        includes(:boosted_content_keywords).
        where(FieldMatchers.build(substring, boosted_contents: %w{title url description}, boosted_content_keywords: %w{value})) if substring.present?
  end

  searchable :auto_index => false do
    integer :affiliate_id
    text :title, :stored => true, :boost => 10.0 do |boosted_content|
      CGI::escapeHTML(boosted_content.title) if boosted_content.affiliate.locale == "en"
    end
    text :description, :stored => true, :boost => 4.0 do |boosted_content|
      CGI::escapeHTML(boosted_content.description) if boosted_content.affiliate.locale == "en"
    end
    text :keywords do |boosted_content|
      boosted_content.boosted_content_keywords.map { |keyword| keyword.value } if boosted_content.boosted_content_keywords.present? and
        boosted_content.affiliate.locale == "en"
    end
    text :title_es, :stored => true, :boost => 10.0, :as => "title_text_es" do |boosted_content|
      CGI::escapeHTML(boosted_content.title) if boosted_content.affiliate.locale == "es"
    end
    text :description_es, :stored => true, :boost => 4.0, :as => "description_text_es" do |boosted_content|
      CGI::escapeHTML(boosted_content.description) if boosted_content.affiliate.locale == "es"
    end
    text :keywords_es, :as => "keywords_text_es" do |boosted_content|
      boosted_content.boosted_content_keywords.map { |keyword| keyword.value } if boosted_content.boosted_content_keywords.present? and
        boosted_content.affiliate.locale == "es"
    end
    boolean :is_active, :using => :is_active?
    time :publish_start_on, :trie => true
    time :publish_end_on, :trie => true
  end

  HUMAN_ATTRIBUTE_NAME_HASH = {
      :publish_start_on => "Publish start date",
      :publish_end_on => "Publish end date",
      :url => "URL"
  }

  class << self
    include QueryPreprocessor

    def search_for(query, affiliate, page = 1, per_page = 3)
      sanitized_query = preprocess(query)
      return nil if sanitized_query.blank?
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => {:model=> self.name, :term => sanitized_query, :affiliate => affiliate.name}) do
        search do
          fulltext sanitized_query do
            highlight :title, :description, :title_es, :description_es, :frag_list_builder => 'single'
          end
          with(:affiliate_id, affiliate.id)
          with(:is_active, true)
          with(:publish_start_on).less_than(Date.current)
          any_of do
            with(:publish_end_on).greater_than(Date.current)
            with :publish_end_on, nil
          end
          paginate :page => page, :per_page => per_page
        end rescue nil
      end
    end

    def human_attribute_name(attribute_key_name, options = {})
      HUMAN_ATTRIBUTE_NAME_HASH[attribute_key_name.to_sym] || super
    end
  end

  def as_json(options = {})
    {:title => title, :url => url, :description => description}
  end

  def to_xml(options = { :indent => 0, :root => 'boosted-result' })
    { :title => title, :url => url, :description => description }.to_xml(options)
  end

  def destroy_and_update_attributes(params)
    destroy_on_blank(params[:boosted_content_keywords_attributes], :value)
    touch if update_attributes(params)
  end

  private

  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^https?://}i
  end
end
