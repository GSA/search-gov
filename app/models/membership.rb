class Membership < ActiveRecord::Base
  include Dupable

  belongs_to :affiliate
  belongs_to :user

  scope :daily_snapshot_receivers, where(gets_daily_snapshot_email: true)

  def label
    "#{affiliate.name}:#{user.email}"
  end
end
