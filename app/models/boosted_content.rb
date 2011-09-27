class BoostedContent < ActiveRecord::Base
  require 'rexml/document'

  STATUSES = %w( active inactive )
  STATUS_OPTIONS = STATUSES.collect { |status| [status.humanize, status] }

  cattr_reader :per_page
  @@per_page = 20

  belongs_to :affiliate

  validates_presence_of :title, :url, :description, :locale, :publish_start_on
  validates_uniqueness_of :url, :message => "has already been boosted", :scope => "affiliate_id"
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES, :message => 'must be selected'
  validates_inclusion_of :status, :in => STATUSES, :message => 'must be selected'
  validate :publish_start_and_end_dates

  before_save :ensure_http_prefix_on_url

  searchable :auto_index => false do
    text :title, :boost => 10.0
    text :description, :boost => 4.0
    text :keywords do
      keywords.split(',') unless keywords.nil?
    end
    string :affiliate_name do |boosted_content|
      if boosted_content.affiliate_id.nil?
        Affiliate::USAGOV_AFFILIATE_NAME
      elsif Affiliate.find_by_id(boosted_content.affiliate_id)
        boosted_content.affiliate.name
      else
        nil
      end
    end
    string :locale
    string :status
    date :publish_start_on
    date :publish_end_on
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

  def self.search_for(query, affiliate = nil, locale = I18n.default_locale.to_s, page = 1, per_page = 3)
    affiliate_name = (affiliate ? affiliate.name : Affiliate::USAGOV_AFFILIATE_NAME)
    ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => {:model=> self.name, :term => query, :affiliate => affiliate_name, :locale => locale}) do
      search do
        fulltext query do
          highlight :title, :description, :max_snippets => 1, :fragment_size => 255, :merge_continuous_fragments => true
        end
        with(:affiliate_name, affiliate_name)
        with(:locale, locale)
        with(:status, 'active')
        with(:publish_start_on).less_than(Time.current)
        any_of do
          with(:publish_end_on).greater_than(Time.current)
          with :publish_end_on, nil
        end
        paginate :page => page, :per_page => per_page
      end rescue nil
    end
  end

  def self.process_boosted_content_xml_upload_for(affiliate, xml_file)
    existing = affiliate.boosted_contents.inject({}) do |hash, bc|
      hash[bc.url] = bc
      hash
    end

    counts = {:created => 0, :updated => 0}
    begin
      doc=REXML::Document.new(xml_file.read)
      transaction do
        doc.root.each_element('//entry') do |entry|
          info = {
            :url => entry.elements["url"].first.to_s,
            :title => entry.elements["title"].first.to_s,
            :description => entry.elements["description"].first.to_s,
            :affiliate => affiliate,
            :locale => 'en',
            :status => 'active',
            :publish_start_on => Date.current
          }
          if matching = existing[info[:url]]
            matching.update_attributes(info)
            counts[:updated] += 1
          else
            create!(info)
            counts[:created] += 1
          end
        end
      end
    rescue
      Rails.logger.warn "Problem processing boosted Content XML document: #{$!}"
      Sunspot.index(affiliate.boosted_contents)
      return false
    end
    counts
  end

  def self.human_attribute_name(attribute_key_name, options = {})
    HUMAN_ATTRIBUTE_NAME_HASH[attribute_key_name.to_sym] || super
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

  private
  def publish_start_and_end_dates
    start_date = publish_start_on.to_s.to_date unless publish_start_on.blank?
    end_date = publish_end_on.to_s.to_date unless publish_end_on.blank?
    if start_date.present? and end_date.present? and start_date > end_date
      errors.add(:base, "Publish end date can't be before publish start date")
    end
  end

  def ensure_http_prefix_on_url
    self.url = "http://#{self.url}" unless self.url.blank? or self.url =~ %r{^http(s?)://}i
  end
end
