class AddIntervalToOutboundRateLimit < ActiveRecord::Migration
  def up
    add_column :outbound_rate_limits, :interval, :string, default: 'day', limit: 10
    OutboundRateLimit.load_defaults
  end

  def down
    remove_column :outbound_rate_limits, :interval
  end
end
