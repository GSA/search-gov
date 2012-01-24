class AddScopeKeywordsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :scope_keywords, :text
  end

  def self.down
    remove_column :affiliates, :scope_keywords
  end
end
