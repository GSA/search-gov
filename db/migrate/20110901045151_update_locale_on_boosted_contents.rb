class UpdateLocaleOnBoostedContents < ActiveRecord::Migration
  def self.up
    change_column_default :boosted_contents, :locale, nil
  end

  def self.down
    change_column_default :boosted_contents, :locale, "en"
  end
end
