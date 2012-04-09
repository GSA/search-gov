class Connection < ActiveRecord::Base
  belongs_to :affiliate
  belongs_to :connected_affiliate, :class_name => "Affiliate"
  validates_presence_of :connected_affiliate_id, :label
end
