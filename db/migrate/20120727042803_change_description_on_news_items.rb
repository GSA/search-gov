class ChangeDescriptionOnNewsItems < ActiveRecord::Migration
  def up
    change_column :news_items, :description, :text, :null => true
  end

  def down
    change_column :news_items, :description, :text, :null => false
  end
end
