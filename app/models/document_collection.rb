class DocumentCollection < ApplicationRecord
  include Dupable
  DEPTH_WHEN_BING_FAILS = 3

  serialize :sitelink_generator_names, Array

  belongs_to :affiliate
  has_one :navigation, :as => :navigable, :dependent => :destroy
  has_many :url_prefixes, -> { order 'prefix' }, dependent: :destroy
  scope :navigable_only, -> { joins(:navigation).where(:navigations => {:is_active => true}).joins(:url_prefixes).select('distinct document_collections.*') }
  validates_presence_of :name, :affiliate_id
  validates_uniqueness_of :name, :scope => :affiliate_id, :case_sensitive => false
  validate :url_prefixes_cannot_be_blank
  after_validation :update_error_keys

  accepts_nested_attributes_for :url_prefixes, :allow_destroy => true, :reject_if => proc { |a| a['prefix'].blank? }
  accepts_nested_attributes_for :navigation

  def destroy_and_update_attributes(params)
    destroy_on_blank(params[:url_prefixes_attributes], :prefix)
    update_attributes(params)
  end

  def depth
    url_prefixes.reduce(0) { |depth, url_prefix| [depth, url_prefix.depth].max }
  end

  def too_deep_for_bing?
    depth >= DocumentCollection::DEPTH_WHEN_BING_FAILS
  end

  def assign_sitelink_generator_names!
    self.sitelink_generator_names = SitelinkGeneratorUtils.matching_generator_names url_prefixes.pluck(:prefix)
    save!
  end

  def sitelink_generator_names_as_str
    sitelink_generator_names.join(',')
  end

  private

  def url_prefixes_cannot_be_blank
    errors.add(:base, 'Collection must have 1 or more URL prefixes') if url_prefixes.blank? or url_prefixes.all?(&:marked_for_destruction?)
  end

  def update_error_keys
    swap_error_key(:"url_prefixes.prefix", :url_prefix)
  end
end
