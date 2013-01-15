class BoostedContent < ActiveRecord::Base
  require 'rexml/document'

  STATUSES = %w( active inactive )
  STATUS_OPTIONS = STATUSES.collect { |status| [status.humanize, status] }

  cattr_reader :per_page
  @@per_page = 20

  belongs_to :affiliate
  has_many :boosted_content_keywords, :dependent => :destroy
  accepts_nested_attributes_for :boosted_content_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }

  validates :affiliate, :presence => true
  validates_presence_of :title, :url, :description, :publish_start_on
  validates_uniqueness_of :url, :message => "has already been boosted", :scope => "affiliate_id"
  validates_inclusion_of :status, :in => STATUSES, :message => 'must be selected'
  validate :publish_start_and_end_dates
  before_save :ensure_http_prefix_on_url

  scope :recent, { :order => 'updated_at DESC, id DESC', :limit => 5 }

  searchable :auto_index => false do
    integer :affiliate_id
    text :title, :stored => true, :boost => 10.0 do |boosted_content|
      boosted_content.title if boosted_content.affiliate.locale == "en"
    end
    text :description, :stored => true, :boost => 4.0 do |boosted_content|
      boosted_content.description if boosted_content.affiliate.locale == "en"
    end
    text :keywords do |boosted_content|
      boosted_content.boosted_content_keywords.map { |keyword| keyword.value } if boosted_content.boosted_content_keywords.present? and
        boosted_content.affiliate.locale == "en"
    end
    text :title_es, :stored => true, :boost => 10.0, :as => "title_text_es" do |boosted_content|
      boosted_content.title if boosted_content.affiliate.locale == "es"
    end
    text :description_es, :stored => true, :boost => 4.0, :as => "description_text_es" do |boosted_content|
      boosted_content.description if boosted_content.affiliate.locale == "es"
    end
    text :keywords_es, :as => "keywords_text_es" do |boosted_content|
      boosted_content.boosted_content_keywords.map { |keyword| keyword.value } if boosted_content.boosted_content_keywords.present? and
        boosted_content.affiliate.locale == "es"
    end
    boolean :is_active, :using => :is_active?
    time :publish_start_on, :trie => true
    time :publish_end_on, :trie => true
  end

  STATUSES.each do |status|
    define_method "is_#{status}?" do
      self.status == status
    end
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

    def process_boosted_content_bulk_upload_for(affiliate, bulk_upload_file)
      filename = bulk_upload_file.original_filename.downcase unless bulk_upload_file.blank?
      return { :success => false, :error_message => "Your filename should have .xml, .csv or .txt extension."} unless filename =~ /\.(xml|csv|txt)$/
      if filename =~ /xml$/
        process_boosted_content_xml_upload_for affiliate,  bulk_upload_file
      else
        process_boosted_content_csv_upload_for affiliate,  bulk_upload_file
      end
    end

    def human_attribute_name(attribute_key_name, options = {})
      HUMAN_ATTRIBUTE_NAME_HASH[attribute_key_name.to_sym] || super
    end
  end

  def self.sayt_for(affiliate_id, query, limit)
    select(%w(title url))
        where("affiliate_id = ? AND title LIKE ? AND status = 'active'", affiliate_id, "#{query}%").
        where('publish_start_on <= CURDATE() AND (publish_end_on >= CURDATE() OR ISNULL(publish_end_on))').
        order('title ASC').
        limit(limit)
  end

  def as_json(options = {})
    {:title => title, :url => url, :description => description}
  end

  def to_xml(options = { :indent => 0, :root => 'boosted-result' })
    { :title => title, :url => url, :description => description }.to_xml(options)
  end

  def display_status
    status.humanize
  end

  def destroy_and_update_attributes(params)
    params[:boosted_content_keywords_attributes].each do |keyword_attributes|
      keyword = keyword_attributes[1]
      keyword[:_destroy] = true if keyword[:value].blank?
    end
    update_attributes(params)
  end

  protected

  def self.process_boosted_content_xml_upload_for(affiliate, xml_file)
    results = { :created => 0, :updated => 0, :success => false }
    boosted_contents = []
    begin
      doc=REXML::Document.new(xml_file.read)
      transaction do
        doc.root.each_element('//entry') do |entry|
          info = {
            :url => entry.elements["url"].first.to_s,
            :title => entry.elements["title"].first.to_s,
            :description => entry.elements["description"].first.to_s,
            :affiliate_id => affiliate.id
          }
          boosted_contents << import_boosted_content(results, info)
        end
      end
      Sunspot.index(boosted_contents)
      results[:success] = true
    rescue
      results[:error_message] = "Your XML document could not be processed. Please check the format and try again."
      Rails.logger.warn "Problem processing boosted Content XML document: #{$!}"
    end
    results
  end

  def self.process_boosted_content_csv_upload_for(affiliate, csv_file)
    boosted_contents = []
    results = { :created => 0, :updated => 0, :success => false }
    begin
      transaction do
        CSV.parse(csv_file.read, :skip_blanks => true) do |row|
          info = {
              :title => row[0],
              :url => row[1],
              :description => row[2],
              :affiliate_id => affiliate.id
          }
          boosted_contents << import_boosted_content(results, info)
        end
      end
      Sunspot.index(boosted_contents)
      results[:success] = true
    rescue
      results[:error_message] = "Your CSV document could not be processed. Please check the format and try again."
      Rails.logger.warn "Problem processing boosted Content CSV document: #{$!}"
    end
    results
  end

  def self.import_boosted_content(results, attributes)

    boosted_content_attributes = attributes.merge({ :status => 'active',
                                                    :publish_start_on => Date.current })
    boosted_content = find_or_initialize_by_url(boosted_content_attributes)
    boosted_content.affiliate_id = attributes[:affiliate_id]
    if boosted_content.new_record?
      boosted_content.save!
      results[:created] += 1
    else
      boosted_content.update_attributes!(boosted_content_attributes)
      results[:updated] += 1
    end
    boosted_content
  end

  private

  def publish_start_and_end_dates
    start_date = publish_start_on.to_s.to_date unless publish_start_on.blank?
    end_date = publish_end_on.to_s.to_date unless publish_end_on.blank?
    if start_date.present? and end_date.present? and start_date > end_date
      errors.add(:base, "Publish end date can't be before publish start date")
    end
  end

  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^https?://}i
  end
end
