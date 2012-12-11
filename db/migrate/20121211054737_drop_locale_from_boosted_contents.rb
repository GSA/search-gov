class DropLocaleFromBoostedContents < ActiveRecord::Migration
  def change
    remove_column :boosted_contents, :locale
  end
end
