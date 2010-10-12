class Affiliate < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :within=> (3..33)
  validates_format_of :name, :with=> /^[\w.-]+$/i
  belongs_to :user
  belongs_to :affiliate_template
  has_many :boosted_sites, :dependent => :destroy
  has_many :sayt_suggestions, :dependent => :destroy
  after_destroy :remove_boosted_sites_from_index
  
  USAGOV_AFFILIATE_NAME = 'usasearch.gov'

  def template
    affiliate_template || DefaultAffiliateTemplate
  end

  private

  def remove_boosted_sites_from_index
    boosted_sites.each { |bs| bs.remove_from_index }
  end

end
