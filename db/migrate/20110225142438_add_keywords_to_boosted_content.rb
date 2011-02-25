class AddKeywordsToBoostedContent < ActiveRecord::Migration
  def self.up
    add_column :boosted_contents, :keywords, :text
  end

  def self.down
    remove_column :boosted_contents, :keywords
  end
end
