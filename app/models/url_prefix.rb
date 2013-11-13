class UrlPrefix < ActiveRecord::Base
  before_validation :ensure_protocol_and_trailing_slash_on_prefix
  validates_presence_of :prefix
  validates_uniqueness_of :prefix, :scope => :document_collection_id, :case_sensitive => false
  validates_format_of :prefix, :with => /\Ahttps?:\/\/[a-z0-9]+([\-\.][a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/]\S*)?\/\z/ix
  validates_url :prefix
  validates_length_of :prefix, :maximum => 100
  belongs_to :document_collection

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
      self.prefix = "http://#{self.prefix}" unless self.prefix =~ %r{^https?://}i
      self.prefix = "#{self.prefix}/" unless self.prefix.ends_with?("/")
    end
  end
end