class FeaturedCollection < ActiveRecord::Base
  STATUSES = %w( active inactive )
  STATUS_OPTIONS = STATUSES.collect { |status| [status.humanize, status] }

  cattr_reader :per_page
  @@per_page = 20

  validates_presence_of :title
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES, :message => 'must be selected'
  validates_inclusion_of :status, :in => STATUSES, :message => 'must be selected'
  validate :minimum_keywords
  validate :publish_start_and_end_dates

  belongs_to :affiliate
  has_many :featured_collection_keywords, :dependent => :destroy
  has_many :featured_collection_links, :dependent => :destroy

  accepts_nested_attributes_for :featured_collection_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }
  accepts_nested_attributes_for :featured_collection_links, :allow_destroy => true, :reject_if => proc { |a| a['title'].blank? and a['url'].blank? }

  def destroy_and_update_attributes(params)
    params[:featured_collection_keywords_attributes].each do |keyword_attributes|
      keyword = keyword_attributes[1]
      keyword[:_destroy] = true if keyword[:value].blank?
    end
    params[:featured_collection_links_attributes].each do |link_attributes|
      link = link_attributes[1]
      link[:_destroy] = true if link[:title].blank? and link[:url].blank?
    end
    update_attributes(params)
  end

  def display_status
    status.humanize
  end

  private
  def minimum_keywords
    errors.add(:base, "One or more keywords are required") unless self.featured_collection_keywords.detect do |keyword|
      keyword.value.present? and !keyword.marked_for_destruction?
    end
  end

  def publish_start_and_end_dates
    start_date = publish_start_on.to_s.to_date unless publish_start_on.blank?
    end_date = publish_end_on.to_s.to_date unless publish_end_on.blank?
    if start_date.present? and end_date.present? and start_date > end_date
      errors.add(:base, "Publish end date can't be before publish start date")
    end
  end
end
