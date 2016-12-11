class AddAffiliateBingV5Key < ActiveRecord::Migration
  def change
    add_column :affiliates, :bing_v5_key, :string, limit: 32
  end
end
