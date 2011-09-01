class AddStatusAndPublishDatesToBoostedContents < ActiveRecord::Migration
  def self.up
    add_column :boosted_contents, :status, :string, :null => false
    add_column :boosted_contents, :publish_start_on, :date, :null => false
    add_column :boosted_contents, :publish_end_on, :date
  end

  def self.down
    remove_column :boosted_contents, :publish_end_on
    remove_column :boosted_contents, :publish_start_on
    remove_column :boosted_contents, :status
  end
end
