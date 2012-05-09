class RemoveTopPickFeature < ActiveRecord::Migration
  class Feature < ActiveRecord::Base
  end

  def self.up
    feature = Feature.find_by_internal_name 'top_picks'
    feature.destroy if feature
  end

  def self.down
  end
end