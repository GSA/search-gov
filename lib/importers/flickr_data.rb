module FlickrData
  def self.import_profile(site, url)
    profile_type = detect_profile_type url

    profile_id = lookup_profile_id(profile_type, url) if profile_type
    return unless profile_id

    site.flickr_profiles.
      where(profile_id: profile_id, profile_type: profile_type).
      first_or_create!(url: url)
  end

  def self.lookup_profile_id(profile_type, url)
    lookup_method = "lookup#{profile_type.capitalize}"
    flickr.urls.send(lookup_method, url: url)['id'] rescue nil
  end

  def self.detect_profile_type(url)
    case url
    when %r[/photos/] then
      'user'
    when %r[/groups/] then
      'group'
    end
  end
end
