class CreateSuggestionBlocks < ActiveRecord::Migration
  create_table :suggestion_blocks do |t|
    t.string :query, null: false

    t.timestamps
  end
end
