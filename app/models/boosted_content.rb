class BoostedContent < ActiveRecord::Base
  include ActiveRecordExtension
  include BestBet
  extend AttributeSquisher

  cattr_reader :per_page
  @@per_page = 20

  belongs_to :affiliate
  has_many :boosted_content_keywords, dependent: :destroy, order: 'value'
  accepts_nested_attributes_for :boosted_content_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }

  before_validation_squish :title, :url, :description
  validates :affiliate, :presence => true
  validates_presence_of :title, :url, :description, :publish_start_on
  validates_uniqueness_of :url, :message => "has already been boosted", :scope => "affiliate_id", :case_sensitive => false
  before_save :ensure_http_prefix_on_url, :sanitize_html_in_fields

  scope :recent, { :order => 'updated_at DESC, id DESC', :limit => 5 }
  scope :substring_match, -> substring do
    select('DISTINCT boosted_contents.*').
        includes(:boosted_content_keywords).
        where(FieldMatchers.build(substring, boosted_contents: %w{title url description}, boosted_content_keywords: %w{value})) if substring.present?
  end

  HUMAN_ATTRIBUTE_NAME_HASH = {
      :publish_start_on => "Publish start date",
      :publish_end_on => "Publish end date",
      :url => "URL"
  }

  class << self
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

  def sanitize_html_in_fields
    self.title = Sanitize.clean(self.title)
    self.description = Sanitize.clean(self.description)
  end
end
