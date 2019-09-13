class AffiliateTwitterSetting < ApplicationRecord
  include Dupable

  belongs_to :affiliate
  belongs_to :twitter_profile
end
