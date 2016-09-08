class AffiliateTwitterSetting < ActiveRecord::Base
  include Dupable

  belongs_to :affiliate
  belongs_to :twitter_profile
end
