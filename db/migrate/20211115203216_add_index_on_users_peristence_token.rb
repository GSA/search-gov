class AddIndexOnUsersPeristenceToken < ActiveRecord::Migration[6.0]
  def change
    add_index :users, [:persistence_token], unique: true
  end
end
