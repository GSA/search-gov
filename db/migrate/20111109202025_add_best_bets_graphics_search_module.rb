class AddBestBetsGraphicsSearchModule < ActiveRecord::Migration
  def self.up
    SearchModule.create(:tag => "BBG", :display_name=> "Best Bets: Graphics")
  end

  def self.down
    SearchModule.where("tag = 'BBG'").delete_all
  end
end
