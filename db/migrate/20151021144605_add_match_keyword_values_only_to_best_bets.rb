class AddMatchKeywordValuesOnlyToBestBets < ActiveRecord::Migration
  def change
    add_column :boosted_contents, :match_keyword_values_only, :boolean, default: false
    add_column :featured_collections, :match_keyword_values_only, :boolean, default: false
  end
end
