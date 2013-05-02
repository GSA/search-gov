class RemoveScopeKeywordsFromAffiliates < ActiveRecord::Migration
  def change
    remove_column :affiliates, :scope_keywords
  end
end
