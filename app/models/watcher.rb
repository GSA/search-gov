class Watcher < ActiveRecord::Base
  INTERVAL_REGEXP = /\d+[smhdw]/

  belongs_to :user
  belongs_to :affiliate

  validates_presence_of :name, :throttle_period, :check_interval
  validates_uniqueness_of :name, case_sensitive: false
  validates_format_of :check_interval, with: INTERVAL_REGEXP
  validates_format_of :throttle_period, with: INTERVAL_REGEXP
end
