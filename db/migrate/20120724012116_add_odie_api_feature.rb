class AddOdieApiFeature < ActiveRecord::Migration
  class Feature < ActiveRecord::Base
  end

  def self.up
    Feature.create(:internal_name => "odie_api", :display_name => "Odie API Search")
  end

  def self.down
    Feature.find_by_internal_name("odie_api").destroy
  end
end
