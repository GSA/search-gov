class FeaturedCollection < ActiveRecord::Base
  include ActiveRecordExtension
  include BestBet

  CLOUD_FILES_CONTAINER = 'Featured Collections'
  MAXIMUM_IMAGE_SIZE_IN_KB = 512
  LAYOUTS = ['one column', 'two column']
  LAYOUT_OPTIONS = LAYOUTS.collect { |layout| [layout.humanize, layout] }
  LINK_TITLE_SEPARATOR = "!!!sep!!!"

  cattr_reader :per_page
  @@per_page = 20

  validates :affiliate, :presence => true
  validates_presence_of :title, :publish_start_on
  validates_inclusion_of :layout, :in => LAYOUTS, :message => 'must be selected'
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
  before_save :ensure_http_prefix
  before_post_process :check_image_validation
  before_update :clear_existing_image
  scope :recent, { :order => 'updated_at DESC, id DESC', :limit => 5 }
  scope :substring_match, -> substring do
    select('DISTINCT featured_collections.*').
        includes([:featured_collection_keywords, :featured_collection_links]).
        where(FieldMatchers.build(substring, featured_collections: %w{title title_url}, featured_collection_keywords: %w{value},
                                  featured_collection_links: %w(title url))) if substring.present?
  end

  accepts_nested_attributes_for :featured_collection_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }
  accepts_nested_attributes_for :featured_collection_links, :allow_destroy => true, :reject_if => proc { |a| a['title'].blank? and a['url'].blank? }

  attr_accessor :mark_image_for_deletion

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
    string :status
    date :publish_start_on
    date :publish_end_on
    text :title, :stored => true, :boost => 10.0 do
      CGI::escapeHTML title
    end
    text :link_titles, :stored => true, :boost => 4.0 do
      featured_collection_links.map { |link| CGI::escapeHTML link.title }.join(LINK_TITLE_SEPARATOR)
    end
    text :keyword_values do
      featured_collection_keywords.map { |keyword| keyword.value }
    end
  end

  class << self
    include QueryPreprocessor

    def search_for(query, affiliate)
      sanitized_query = preprocess(query)
      return nil if sanitized_query.blank?
      ActiveSupport::Notifications.instrument("solr_search.usasearch", :query => { :model => self.name, :term => sanitized_query, :affiliate => affiliate.name }) do
        begin
          search do
            with :affiliate_id, affiliate.id
            with :status, "active"
            any_of do
              with(:publish_start_on).less_than(Time.current)
            end
            any_of do
              with(:publish_end_on).greater_than(Time.current)
              with :publish_end_on, nil
            end
            keywords sanitized_query do
              highlight :title, :link_titles, :frag_list_builder => 'single'
            end
            paginate :page => 1, :per_page => 1
          end
        rescue RSolr::Error::Http => e
          Rails.logger.warn "Error FeaturedCollection#search_for: #{e.to_s}"
          nil
        end
      end
    end

  end

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
