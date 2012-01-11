class IndexedDomain < ActiveRecord::Base
  belongs_to :affiliate
  has_many :indexed_documents, :dependent => :destroy
  validates_presence_of :domain, :affiliate_id
  validates_uniqueness_of :domain, :scope => :affiliate_id
end