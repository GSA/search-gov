class FlickrProfileImporter
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(flickr_profile_id)
    return unless (flickr_profile = FlickrProfile.find_by_id(flickr_profile_id))
    flickr_profile.import_photos
  end
end