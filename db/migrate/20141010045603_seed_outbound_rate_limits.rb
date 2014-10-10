class SeedOutboundRateLimits < ActiveRecord::Migration
  def up
    OutboundRateLimit.load_defaults
  end

  def down
  end
end
