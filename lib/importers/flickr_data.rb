class FlickrData
  include FlickrDsl
  attr_reader :new_profile_created
  alias_method :new_profile_created?, :new_profile_created

  def initialize(site, url)
    @site, @url = site, url
    @new_profile_created = false
  end

  def import_profile
    profile_type = detect_flickr_profile_type @url

    profile_id = lookup_flickr_profile_id(profile_type, @url) if profile_type
    return unless profile_id

    @site.flickr_profiles.
      where(profile_id: profile_id, profile_type: profile_type).
      first_or_create!(url: @url) do |new_flickr_profile|
      @new_profile_created = true
    end
  end

end
