class DestroyOdieApiFeature < ActiveRecord::Migration
  class Feature < ActiveRecord::Base
  end

  def self.up
    Feature.where(internal_name: 'odie_api').destroy_all
  end

  def self.down
    Feature.create(internal_name: "odie_api", display_name: "Odie API Search")
  end
end
