class AddSrelSearchModule < ActiveRecord::Migration
  def self.up
    SearchModule.create!(:tag => "SREL", :display_name => "SAYT Related Search")
  end

  def self.down
    SearchModule.find_by_tag("SREL").delete
  end
end
