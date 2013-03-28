class AffiliateTwitterSetting < ActiveRecord::Base
  belongs_to :affiliate
  belongs_to :twitter_profile
end