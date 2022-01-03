class MigrateYoutubeHandleOnAffiliates < ActiveRecord::Migration
  def self.up
    Affiliate.where("youtube_handle IS NOT NULL and TRIM(youtube_handle) <> ''").each do |a|
      a.update_attributes!(:youtube_handles => [a.youtube_handle])
    end
  end

  def self.down
  end
end
