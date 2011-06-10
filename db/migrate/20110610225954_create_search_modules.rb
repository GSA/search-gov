class CreateSearchModules < ActiveRecord::Migration
  def self.up
    create_table :search_modules do |t|
      t.string :tag, :null => false
      t.string :display_name, :null => false

      t.timestamps
    end
    add_index :search_modules, :tag, :unique => true
    {"BWEB" => "Bing Web",
     "IMAG" => "Bing Image",
     "BOOS" => "Boosted Site",
     "SPOT" => "Spotlight",
     "RECALL"=>"Recall",
     "BSPEL" => "Bing Spelling Suggestion",
     "OVER" => "User override of Bing Spelling Suggestion",
     "FAQS"=> "FAQ",
     "CREL"=>"Related Topics"}.each { |tag, display_name| SearchModule.create!(:tag => tag, :display_name => display_name) }
  end

  def self.down
    drop_table :search_modules
  end
end
