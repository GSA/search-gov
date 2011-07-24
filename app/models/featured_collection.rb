class FeaturedCollection < ActiveRecord::Base
  STATUS = %w( active inactive )

  cattr_reader :per_page
  @@per_page = 20

  validates_presence_of :title
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES, :message => 'must be selected'
  validates_inclusion_of :status, :in => STATUS, :message => 'must be selected'

  belongs_to :affiliate
  has_many :featured_collection_keywords, :dependent => :destroy
  has_many :featured_collection_links, :dependent => :destroy

  accepts_nested_attributes_for :featured_collection_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }
  accepts_nested_attributes_for :featured_collection_links, :allow_destroy => true, :reject_if => proc { |a| a['title'].blank? and a['url'].blank? }
end
