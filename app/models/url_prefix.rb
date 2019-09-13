class UrlPrefix < ApplicationRecord
  include Dupable

  before_validation :ensure_protocol_and_trailing_slash_on_prefix
  validates_presence_of :prefix
  validates_uniqueness_of :prefix, :scope => :document_collection_id, :case_sensitive => false
  validates_format_of :prefix, :with => /\Ahttps?:\/\/[a-z0-9]+([\-\.][a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/]\S*)?\/\z/ix
  validates_url :prefix
  validates_length_of :prefix, maximum: 255
  belongs_to :document_collection

  def self.do_not_dup_attributes
    @@do_not_dup_attributes ||= %w(document_collection_id).freeze
  end

  def label
    prefix
  end

  def depth
    URI.parse(prefix).path.scan(%r[/\S]).count
  end

  private

  def ensure_protocol_and_trailing_slash_on_prefix
    unless self.prefix.blank?
      self.prefix.strip!
      self.prefix.downcase!
      self.prefix = "http://#{self.prefix}" unless self.prefix =~ %r{^https?://}i
      self.prefix = "#{self.prefix}/" unless self.prefix.ends_with?("/")
    end
  end
end
