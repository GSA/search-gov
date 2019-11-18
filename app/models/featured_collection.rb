class FeaturedCollection < ApplicationRecord
  extend HumanAttributeName
  include BestBet

  MAXIMUM_IMAGE_SIZE_IN_KB = 512

  cattr_reader :per_page
  @@per_page = 20

  validates :affiliate, :presence => true
  validates_presence_of :title, :publish_start_on

  belongs_to :affiliate
  has_many :featured_collection_keywords, :dependent => :destroy
  has_many :featured_collection_links, -> { order 'position ASC' }, :dependent => :destroy

  has_attached_file :image,
                    styles: { medium: "125x125", small: "100x100" },
                    storage: :s3,
                    path: "#{Rails.env}/featured_collection/:id/image/:updated_at/:style/:filename",
                    s3_credentials: Rails.application.secrets.aws_image_bucket,
                    url: ':s3_alias_url',
                    s3_host_alias: Rails.application.secrets.aws_image_bucket[:s3_host_alias],
                    s3_protocol: 'https',
                    s3_region: Rails.application.secrets.aws_image_bucket[:s3_region]

  validates_attachment_size :image,
                            in: (1..MAXIMUM_IMAGE_SIZE_IN_KB.kilobytes),
                            message: "must be under #{MAXIMUM_IMAGE_SIZE_IN_KB} KB"
  validates_attachment_content_type :image,
                                    content_type: %w{ image/gif image/jpeg image/pjpeg image/png image/x-png },
                                    message: "must be GIF, JPG, or PNG"

  before_validation do |record|
    AttributeProcessor.sanitize_attributes record, :title
    AttributeProcessor.squish_attributes record,
                                         :image_alt_text,
                                         :title,
                                         :title_url,
                                         assign_nil_on_blank: true
    AttributeProcessor.prepend_attributes_with_http record, :title_url
  end

  after_validation :update_errors_keys
  before_update :clear_existing_image
  scope :substring_match, -> substring do
    if substring.present?
      select('DISTINCT featured_collections.*').
        eager_load([:featured_collection_keywords, :featured_collection_links]).
        where(FieldMatchers.build(substring, featured_collections: %w{title title_url}, featured_collection_keywords: %w{value},
                                  featured_collection_links: %w(title url)))
    end
  end

  accepts_nested_attributes_for :featured_collection_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }
  accepts_nested_attributes_for :featured_collection_links, :allow_destroy => true, :reject_if => proc { |a| a['title'].blank? and a['url'].blank? }

  validate { |record| record.match_keyword_values_only_requires_keywords(featured_collection_keywords) }

  attr_accessor :mark_image_for_deletion

  def self.do_not_dup_attributes
    @@do_not_dup_attributes ||= begin
      column_names.select { |c| c =~ /\Aimage\_/ }.push('affiliate_id').freeze
    end
  end

  def self.human_attribute_name_hash
    @@human_attribute_name_hash ||= {
      publish_start_on: 'Publish start date'
    }.freeze
  end

  def destroy_and_update_attributes(params)
    destroy_on_blank(params[:featured_collection_keywords_attributes], :value)
    destroy_on_blank(params[:featured_collection_links_attributes], :title, :url)
    touch if update_attributes(params)
  end

  def as_json(options = {})
    image_url = build_image_url
    hash = { id: id,
             title: title,
             title_url: title_url }

    if image_url
      hash[:image_url] = image_url
      hash[:image_alt_text] = image_alt_text
    end

    hash[:links] = featured_collection_links.collect(&:as_json)

    options[:except].each do |ex|
      hash.delete(ex)
    end unless options[:except].nil?
    hash
  end

  private

  def clear_existing_image
    if image? and !image.dirty? and mark_image_for_deletion == '1'
      image.clear
      self.image_alt_text = nil
    end
  end

  def update_errors_keys
    swap_error_key :'featured_collection_links.title',
                   :'best_bets:_graphics_links.title'
    swap_error_key :'featured_collection_links.url',
                   :'best_bets:_graphics_links.url'
  end

  def build_image_url(size = :medium)
    if image_file_name.present?
      image.url(size) rescue nil
    end
  end
end
