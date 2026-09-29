class AddNotesToAffiliates < ActiveRecord::Migration[7.1]
  def change
    add_column :affiliates, :notes, :text
  end
end
