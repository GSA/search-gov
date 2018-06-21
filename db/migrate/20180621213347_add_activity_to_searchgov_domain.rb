class AddActivityToSearchgovDomain < ActiveRecord::Migration
  def change
    add_column :searchgov_domains, :activity, :string, limit: 100, null: false, default: 'idle'
    add_index :searchgov_domains, :status, length: 100
    add_index :searchgov_domains, :activity
  end
end
