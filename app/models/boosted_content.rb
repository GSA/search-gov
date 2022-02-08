# frozen_string_literal: true

class BoostedContent < ApplicationRecord
  extend HumanAttributeName
  include BestBet

  cattr_reader :per_page
  @@per_page = 20

  belongs_to :affiliate
  has_many :boosted_content_keywords, -> { order 'value' },
           dependent: :destroy, inverse_of: :boosted_content
  accepts_nested_attributes_for :boosted_content_keywords, :allow_destroy => true, :reject_if => proc { |a| a['value'].blank? }

  before_validation do |record|
    AttributeProcessor.sanitize_attributes record, :title, :description
    AttributeProcessor.squish_attributes record, :title, :url, :description
  end

  validates :affiliate, :presence => true
  validates_presence_of :title, :url, :description, :publish_start_on
  validates_uniqueness_of :url, :message => "has already been boosted", :scope => "affiliate_id", :case_sensitive => false
  validates_format_of :url, with: URI.regexp,
    message: " - Please ensure the URLs are properly formatted, including the http:// or https:// prefix."

  validate { |record| record.match_keyword_values_only_requires_keywords(boosted_content_keywords) }

  scope :substring_match, -> substring do
    if substring.present?
      select('DISTINCT boosted_contents.*').
        eager_load(:boosted_content_keywords).
        where(FieldMatchers.build(substring, boosted_contents: %w{title url description}, boosted_content_keywords: %w{value}))
    end
  end

  def self.human_attribute_name_hash
    @@human_attribute_name_hash ||= {
      publish_start_on: 'Publish start date',
      publish_end_on: 'Publish end date',
      url: 'URL'
    }.freeze
  end

  def as_json(options = {})
    json = { :id => id, :title => title, :url => url, :description => description }
    options[:except].each do |ex|
      json.delete(ex)
    end unless options[:except].nil?
    json
  end

  def to_xml(options = { :indent => 0, :root => 'boosted-result' })
    { :title => title, :url => url, :description => description }.to_xml(options)
  end

  def destroy_and_update_attributes(params)
    destroy_on_blank(params[:boosted_content_keywords_attributes], :value)
    touch if update(params)
  end
end
