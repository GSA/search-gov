class DestroyOdieApiFeature < ActiveRecord::Migration
  class Feature < ActiveRecord::Base
  end

  def self.up
    Feature.destroy_all(:internal_name => 'odie_api')
  end

  def self.down
    Feature.create(:internal_name => "odie_api", :display_name => "Odie API Search")
  end
end
