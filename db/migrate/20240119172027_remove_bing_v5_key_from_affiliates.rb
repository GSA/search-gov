class RemoveBingV5KeyFromAffiliates < ActiveRecord::Migration[7.0]
  def change
    remove_column :affiliates, :bing_v5_key, :string
  end
end
