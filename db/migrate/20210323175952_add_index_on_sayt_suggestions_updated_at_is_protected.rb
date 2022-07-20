class AddIndexOnSaytSuggestionsUpdatedAtIsProtected < ActiveRecord::Migration[5.2]
  def change
    add_index :sayt_suggestions, [:updated_at, :is_protected]
  end
end
