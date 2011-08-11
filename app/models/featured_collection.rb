class FeaturedCollection < ActiveRecord::Base
  CLOUD_FILES_CONTAINER = 'Featured Collections'
  MAXIMUM_IMAGE_SIZE_IN_KB = 512
  STATUSES = %w( active inactive )
  STATUS_OPTIONS = STATUSES.collect { |status| [status.humanize, status] }

  cattr_reader :per_page
  @@per_page = 20

  validates_presence_of :title
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES, :message => 'must be selected'
  validates_inclusion_of :status, :in => STATUSES, :message => 'must be selected'
  validate :minimum_keywords
  validate :publish_start_and_end_dates
  validates_attachment_size :image, :in => (1..MAXIMUM_IMAGE_SIZE_IN_KB.kilobytes), :message => "must be under #{MAXIMUM_IMAGE_SIZE_IN_KB} KB"
  validates_attachment_content_type :image, :content_type => %w{ image/gif image/jpeg image/pjpeg image/png image/x-png }, :message => "must be GIF, JPG, or PNG"

  belongs_to :affiliate
  has_many :featured_collection_keywords, :dependent => :destroy
  has_many :featured_collection_links, :dependent => :destroy
  has_attached_file :image,
                    :styles => { :medium => "200x200", :small => "150x150" },
                    :storage => :cloud_files,
                    :cloudfiles_credentials => "#{Rails.root}/config/rackspace_cloudfiles.yml",
                    :container => CLOUD_FILES_CONTAINER,
                    :path => "#{Rails.env}/:attachment/:updated_at/:id/:style/:basename.:extension",
                    :ssl => true

  before_post_process :check_image_validation
  before_update :clear_existing_image

  accepts_nested_attributes_for :featured_collection_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }
  accepts_nested_attributes_for :featured_collection_links, :allow_destroy => true, :reject_if => proc { |a| a['title'].blank? and a['url'].blank? }

  attr_accessor :mark_image_for_deletion

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
