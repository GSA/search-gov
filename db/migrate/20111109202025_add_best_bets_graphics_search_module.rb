class AddBestBetsGraphicsSearchModule < ActiveRecord::Migration
  def self.up
    SearchModule.create(:tag => "BBG", :display_name=> "Best Bets: Graphics")
  end

  def self.down
    SearchModule.delete_all("tag = 'BBG'")
  end
end
