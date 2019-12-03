class Feature < ApplicationRecord
  validates_presence_of :internal_name, :display_name
  validates_uniqueness_of :internal_name, :display_name
  has_many :affiliate_feature_addition, :dependent => :destroy
  has_many :affiliates, :through => :affiliate_feature_addition

  def label
    display_name
  end

end
