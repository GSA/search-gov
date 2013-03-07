class CatalogPrefix < ActiveRecord::Base
  validates_presence_of :prefix
  validates_uniqueness_of :prefix, :case_sensitive => false
  validates_format_of :prefix, :with => /^http:\/\/[a-z0-9]+([\-\.][a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/]\S*)?$/ix

  def label
    prefix
  end
end