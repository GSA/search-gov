module FlickrDsl
  def detect_flickr_profile_type(url)
    case url
      when %r[/photos/] then
        'user'
      when %r[/groups/] then
        'group'
    end
  end

  def lookup_flickr_profile_id(profile_type, url)
    lookup_method = "lookup#{profile_type.capitalize}"
    flickr.urls.send(lookup_method, url: url)['id'] rescue nil
  end
end
