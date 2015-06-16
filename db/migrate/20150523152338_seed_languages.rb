class SeedLanguages < ActiveRecord::Migration
  def up
    load Rails.root.join('db', 'seeds', 'language.rb')
  end

  def down
    Language.delete_all
  end
end
