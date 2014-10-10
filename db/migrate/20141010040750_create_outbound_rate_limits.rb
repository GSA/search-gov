class CreateOutboundRateLimits < ActiveRecord::Migration
  def change
    create_table :outbound_rate_limits do |t|
      t.string :name, null: false
      t.integer :limit, null: false

      t.timestamps
    end
  end
end
