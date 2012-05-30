class CommonSubstring < ActiveRecord::Base
  belongs_to :indexed_domain
  before_validation :strip_whitespace
  validates_presence_of :substring, :indexed_domain_id, :saturation
  validates_uniqueness_of :substring, :scope => :indexed_domain_id

  after_create :remove_from_indexed_documents

  BATCH_SIZE_FOR_SUBSTRING_STRIPPING = 5

  private

  def remove_from_indexed_documents
    options = {:batch_size => BATCH_SIZE_FOR_SUBSTRING_STRIPPING, :conditions => ['body like ?', '%' + substring + '%']}
    indexed_domain.indexed_documents.html.find_each(options) { |idoc| idoc.remove_common_substring(substring) }
  end

  def strip_whitespace
    self.substring = self.substring.strip if self.substring.present?
  end
end