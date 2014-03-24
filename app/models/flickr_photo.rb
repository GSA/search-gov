class FlickrPhoto < ActiveRecord::Base
  belongs_to :flickr_profile
  validates_presence_of :flickr_id, :flickr_profile
  validates_uniqueness_of :flickr_id, :scope => :flickr_profile_id
  before_save :update_with_raw_tags
    
  def flickr_url
    "http://www.flickr.com/photos/#{self.owner}/#{self.flickr_id}/"
  end
    
  def update_with_raw_tags
    tag_string = get_raw_tags.collect{|tag| tag["raw"]}.join(",")
    self.tags = tag_string if tag_string.present?
  end

  private
  
  def get_photo_info
    flickr.photos.getInfo(:photo_id => self.flickr_id) rescue nil
  end
  
  def get_raw_tags
    photo_info = get_photo_info
    photo_info.nil? ? [] : photo_info["tags"]
  end

end