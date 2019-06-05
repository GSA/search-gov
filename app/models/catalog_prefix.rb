class CatalogPrefix < ApplicationRecord
  validates_presence_of :prefix
  validates_uniqueness_of :prefix, :case_sensitive => false
  validates_url :prefix, schemes: %w(http)

  def label
    prefix
  end
end
