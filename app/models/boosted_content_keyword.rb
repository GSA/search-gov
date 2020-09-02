class BoostedContentKeyword < ApplicationRecord
  include Dupable

  before_validation do |record|
    AttributeProcessor.squish_attributes record, :value
  end

  validates_presence_of :value
  validates_uniqueness_of :value, scope: :boosted_content_id, case_sensitive: false
  validates_format_of :value, with: /\A[^,|]+\z/i, message: "can't contain commas or pipes. Add each keyword (word or phrase) individually by clicking Add Another Keyword."
  belongs_to :boosted_content

  def self.do_not_dup_attributes
    @@do_not_dup_attributes ||= %w(boosted_content_id).freeze
  end

  def label
    value
  end
end
