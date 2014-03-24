class ElasticFlickrPhotoData

  def initialize(flickr_photo)
    @flickr_photo = flickr_photo
  end

  def to_builder
    Jbuilder.new do |json|
      json.(@flickr_photo, :id, :title, :description)
      json.affiliate_id @flickr_photo.flickr_profile.affiliate_id
      json.tags @flickr_photo.tags.split(",") unless @flickr_photo.tags.blank?
      json.language "#{@flickr_photo.flickr_profile.affiliate.locale}_analyzer"
    end
  end

end