class Membership < ApplicationRecord
  include Dupable

  belongs_to :affiliate
  belongs_to :user

  scope :daily_snapshot_receivers, -> {
    where(gets_daily_snapshot_email: true).
      joins(:user).where(users: { approval_status: 'approved' }).
      joins(:affiliate).merge(Affiliate.active)
  }
end
