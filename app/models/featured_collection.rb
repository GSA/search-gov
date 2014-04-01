class FeaturedCollection < ActiveRecord::Base
  include ActiveRecordExtension
  include BestBet

  CLOUD_FILES_CONTAINER = 'Featured Collections'
  MAXIMUM_IMAGE_SIZE_IN_KB = 512

  cattr_reader :per_page
  @@per_page = 20

  validates :affiliate, :presence => true
  validates_presence_of :title, :publish_start_on
  validates_attachment_size :image, :in => (1..MAXIMUM_IMAGE_SIZE_IN_KB.kilobytes), :message => "must be under #{MAXIMUM_IMAGE_SIZE_IN_KB} KB"
  validates_attachment_content_type :image, :content_type => %w{ image/gif image/jpeg image/pjpeg image/png image/x-png }, :message => "must be GIF, JPG, or PNG"

  belongs_to :affiliate
  has_many :featured_collection_keywords, :dependent => :destroy
  has_many :featured_collection_links, :order => 'position ASC', :dependent => :destroy
  has_attached_file :image,
                    :styles => { :medium => "125x125", :small => "100x100" },
                    :storage => :cloud_files,
                    :cloudfiles_credentials => "#{Rails.root}/config/rackspace_cloudfiles.yml",
                    :container => CLOUD_FILES_CONTAINER,
                    :path => "#{Rails.env}/:attachment/:updated_at/:id/:style/:basename.:extension",
                    :ssl => true

  after_validation :update_errors_keys
  before_save :ensure_http_prefix, :sanitize_html_in_title
  before_post_process :check_image_validation
  before_update :clear_existing_image
  scope :substring_match, -> substring do
    select('DISTINCT featured_collections.*').
        includes([:featured_collection_keywords, :featured_collection_links]).
        where(FieldMatchers.build(substring, featured_collections: %w{title title_url}, featured_collection_keywords: %w{value},
                                  featured_collection_links: %w(title url))) if substring.present?
  end

  accepts_nested_attributes_for :featured_collection_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }
  accepts_nested_attributes_for :featured_collection_links, :allow_destroy => true, :reject_if => proc { |a| a['title'].blank? and a['url'].blank? }

  attr_accessor :mark_image_for_deletion

  HUMAN_ATTRIBUTE_NAME_HASH = {
      :publish_start_on => "Publish start date",
  }

  def self.human_attribute_name(attribute_key_name, options = {})
    HUMAN_ATTRIBUTE_NAME_HASH[attribute_key_name.to_sym] || super
  end

  def destroy_and_update_attributes(params)
    destroy_on_blank(params[:featured_collection_keywords_attributes], :value)
    destroy_on_blank(params[:featured_collection_links_attributes], :title, :url)
    touch if update_attributes(params)
  end

  private

  def ensure_http_prefix
    set_http_prefix :title_url, :image_attribution_url
  end

  def sanitize_html_in_title
    self.title = Sanitize.clean(self.title)
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

  def update_errors_keys
    if self.errors.include?(:"featured_collection_links.title")
      error_value = self.errors.delete(:"featured_collection_links.title")
      self.errors.add(:"best_bets:_graphics_links.title", error_value)
    end
    if self.errors.include?(:"featured_collection_links.url")
      error_value = self.errors.delete(:"featured_collection_links.url")
      self.errors.add(:"best_bets:_graphics_links.url", error_value)
    end
  end
end
