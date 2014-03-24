module FlickrPhotosHelper
  def display_flickr_photo_thumbnail(flickr_photo, search, affiliate)
    html = ""
    thumbnail = image_tag(flickr_photo.url_sq, :alt => flickr_photo.title, :title => flickr_photo.title)
    html << tracked_click_link(flickr_photo.flickr_url, thumbnail, search, affiliate, 0, "PHOTO")
    raw html
  end
end