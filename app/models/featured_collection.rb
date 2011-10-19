class FeaturedCollection < ActiveRecord::Base
  CLOUD_FILES_CONTAINER = 'Featured Collections'
  MAXIMUM_IMAGE_SIZE_IN_KB = 512
  STATUSES = %w( active inactive )
  STATUS_OPTIONS = STATUSES.collect { |status| [status.humanize, status] }
  LAYOUTS = ['one column', 'two column']
  LAYOUT_OPTIONS = LAYOUTS.collect { |layout| [layout.humanize, layout]}
  LINK_TITLE_SEPARATOR = "!!!sep!!!"

  cattr_reader :per_page
  @@per_page = 20

  validates_presence_of :title, :publish_start_on
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES, :message => 'must be selected'
  validates_inclusion_of :status, :in => STATUSES, :message => 'must be selected'
  validates_inclusion_of :layout, :in => LAYOUTS, :message => 'must be selected'
  validate :publish_start_and_end_dates
  validates_attachment_size :image, :in => (1..MAXIMUM_IMAGE_SIZE_IN_KB.kilobytes), :message => "must be under #{MAXIMUM_IMAGE_SIZE_IN_KB} KB"
  validates_attachment_content_type :image, :content_type => %w{ image/gif image/jpeg image/pjpeg image/png image/x-png }, :message => "must be GIF, JPG, or PNG"

  belongs_to :affiliate
  has_many :featured_collection_keywords, :dependent => :destroy
  has_many :featured_collection_links, :dependent => :destroy
  has_attached_file :image,
                    :styles => { :medium => "125x125", :small => "100x100" },
                    :storage => :cloud_files,
                    :cloudfiles_credentials => "#{Rails.root}/config/rackspace_cloudfiles.yml",
                    :container => CLOUD_FILES_CONTAINER,
                    :path => "#{Rails.env}/:attachment/:updated_at/:id/:style/:basename.:extension",
                    :ssl => true

  before_save :ensure_http_prefix_on_title_url
  before_post_process :check_image_validation
  before_update :clear_existing_image

  accepts_nested_attributes_for :featured_collection_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }
  accepts_nested_attributes_for :featured_collection_links, :allow_destroy => true, :reject_if => proc { |a| a['title'].blank? and a['url'].blank? }

  attr_accessor :mark_image_for_deletion

  STATUSES.each do |status|
    define_method "is_#{status}?" do
      self.status == status
    end
  end

  LAYOUTS.each do |layout|
    define_method "has_#{layout.parameterize('_')}_layout?" do
      self.layout == layout
    end
  end

  HUMAN_ATTRIBUTE_NAME_HASH = {
      :publish_start_on => "Publish start date",
  }

  searchable do
    integer :affiliate_id
    string :locale
    string :status
    date :publish_start_on
    date :publish_end_on
    text :title, :boost => 10.0
    text :link_titles, :boost => 4.0 do
      featured_collection_links.map { |link| link.title }.join(LINK_TITLE_SEPARATOR)
    end
    text :keyword_values do
      featured_collection_keywords.map { |keyword| keyword.value }
    end
  end

  def self.search_for(query, affiliate, locale)
    affiliate_name = (affiliate ? affiliate.name : Affiliate::USAGOV_AFFILIATE_NAME)
    ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => {:model=> self.name, :term => query, :affiliate => affiliate_name, :locale => locale}) do
      begin
        search do
          if affiliate.nil?
            with :affiliate_id, nil
          else
            with :affiliate_id, affiliate.id
          end
          with :locale, locale
          with :status, "active"
          any_of do
            with(:publish_start_on).less_than(Time.current)
          end
          any_of do
            with(:publish_end_on).greater_than(Time.current)
            with :publish_end_on, nil
          end
          keywords query do
            highlight :title, :link_titles, :fragment_size => 0
          end
          paginate :page => 1, :per_page => 1
        end
      rescue => e
        Rails.logger.error "#{e.message}\n#{e.backtrace.join("\n")}" if Rails.env.development?
        nil
      end
    end
  end

  def self.human_attribute_name(attribute_key_name, options = {})
    HUMAN_ATTRIBUTE_NAME_HASH[attribute_key_name.to_sym] || super
  end

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
  def publish_start_and_end_dates
    start_date = publish_start_on.to_s.to_date unless publish_start_on.blank?
    end_date = publish_end_on.to_s.to_date unless publish_end_on.blank?
    if start_date.present? and end_date.present? and start_date > end_date
      errors.add(:base, "Publish end date can't be before publish start date")
    end
  end

  def ensure_http_prefix_on_title_url
    self.title_url = "http://#{self.title_url}" unless self.title_url.blank? or self.title_url =~ %r{^http(s?)://}i
  end

  def check_image_validation
    valid?
    errors[:image_file_size].blank? and errors[:image_content_type].blank?
  end

  def clear_existing_image
    if image? and !image.dirty? and mark_image_for_deletion == '1'
      image.clear
    end
  end
end
