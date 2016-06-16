class AddFailedLoginCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :failed_login_count, :integer, null: false, default: 0
  end
end
