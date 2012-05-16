class IndexedDomain < ActiveRecord::Base
  belongs_to :affiliate
  has_many :indexed_documents, :dependent => :destroy
  has_many :common_substrings, :dependent => :destroy
  validates_presence_of :domain, :affiliate_id
  validates_uniqueness_of :domain, :scope => :affiliate_id

  def self.detect_templates
    all.each {|indexed_domain| Resque.enqueue_with_priority(:low, IndexedDomainTemplateDetector, indexed_domain.id)}
  end

  def label
    domain
  end
end