class Affiliate < ActiveRecord::Base
  validates_presence_of :name, :template
  validates_uniqueness_of :name
  validates_length_of :name, :within=> (3..33)
  validates_format_of :name, :with=> /^[\w.-]+$/i
  belongs_to :user
  belongs_to :template, :class_name => "AffiliateTemplate", :foreign_key => "affiliate_template_id"
  has_many :boosted_sites, :dependent => :destroy
  after_destroy :remove_boosted_sites_from_index

  private

  def remove_boosted_sites_from_index
    boosted_sites.each { |bs| bs.remove_from_index }
  end

end
