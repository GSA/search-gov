class AffiliateTwitterSetting < ActiveRecord::Base
  include Dupable

  attr_accessible :affiliate_id, :twitter_profile_id, :show_lists
  belongs_to :affiliate
  belongs_to :twitter_profile
end
