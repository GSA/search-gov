class WidenDublinCoreFields < ActiveRecord::Migration
  def up
    change_table :news_items do |table|
      table.change :subject, :text
      table.change :contributor, :text
      table.change :publisher, :text
    end
  end

  def down
    change_table :news_items do |table|
      table.change :subject, :string
      table.change :contributor, :string
      table.change :publisher, :string
    end
  end
end
