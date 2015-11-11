class AddAzureCompositeUsageTracking < ActiveRecord::Migration
  def up
    OutboundRateLimit.where(name: 'azure_api').destroy_all
    OutboundRateLimit.load_defaults
  end

  def down
    OutboundRateLimit.load_defaults
  end
end
