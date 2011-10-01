class AddNewsSearchModule < ActiveRecord::Migration
  def self.up
    SearchModule.create(:tag => "NEWS", :display_name=> "Affiliate RSS Indexes")
  end

  def self.down
    SearchModule.delete_all("tag = 'NEWS'")
  end
end