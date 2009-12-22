class Affiliate < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  belongs_to :user
  has_many :boosted_sites

  def boosted_sites_for(query)
    boosted_sites.find_all {|bs| bs.title =~ /#{query}/i }
  end
end
