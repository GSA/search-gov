class RemoveExcludeWebtrendsFromAffiliates < ActiveRecord::Migration
  def up
    remove_column :affiliates, :exclude_webtrends
  end

  def down
    add_column :affiliates, :exclude_webtrends, :boolean, default: false, null: false
  end
end
