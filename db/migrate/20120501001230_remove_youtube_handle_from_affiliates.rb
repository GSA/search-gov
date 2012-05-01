class RemoveYoutubeHandleFromAffiliates < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :youtube_handle
  end

  def self.down
    add_column :affiliates, :youtube_handle, :string
  end
end
