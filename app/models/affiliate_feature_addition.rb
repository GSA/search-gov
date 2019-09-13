class AffiliateFeatureAddition < ApplicationRecord
  validates_presence_of :affiliate_id, :feature_id
  validates_uniqueness_of :affiliate_id, :scope => :feature_id
  belongs_to :affiliate
  belongs_to :feature
end
