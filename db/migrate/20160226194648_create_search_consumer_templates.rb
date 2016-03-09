class CreateSearchConsumerTemplates < ActiveRecord::Migration
  def change
    create_table :search_consumer_templates do |t|
      t.boolean :active, :default => true
      t.boolean :selected, :default => true

      t.belongs_to :affiliate, index: true, :null => false
      t.belongs_to :search_consumer_templateable, polymorphic: true, index: true
      t.timestamps
    end
  end
end