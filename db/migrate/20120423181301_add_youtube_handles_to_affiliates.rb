class AddYoutubeHandlesToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :youtube_handles, :string
  end

  def self.down
    remove_column :affiliates, :youtube_handles
  end
end
