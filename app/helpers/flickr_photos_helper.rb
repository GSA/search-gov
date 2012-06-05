module FlickrPhotosHelper
  def display_flickr_photo_thumbnail(flickr_photo, search, affiliate)
    html = ""
    thumbnail = image_tag(flickr_photo.instance.url_sq, :alt => flickr_photo.instance.title, :title => flickr_photo.instance.title)
    html << tracked_click_link(flickr_photo.instance.flickr_url, thumbnail, search, affiliate, 0, "PHOTO")
    raw html
  end
end