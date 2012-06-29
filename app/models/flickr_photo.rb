class FlickrPhoto < ActiveRecord::Base
  belongs_to :flickr_profile
  validates_presence_of :flickr_id, :flickr_profile
  validates_uniqueness_of :flickr_id, :scope => :flickr_profile_id
  after_create :update_with_raw_tags
  scope :recent, :order => 'date_upload DESC', :limit => 10
  
  searchable do
    text :title
    text :description
    text :tag do |flickr_photo|
      flickr_photo.tags.split(",") unless flickr_photo.tags.blank?
    end
    integer :affiliate_id do |flickr_photo|
      flickr_photo.flickr_profile.affiliate_id
    end
  end
    
  class << self
    include QueryPreprocessor
    
    def search_for(query, affiliate, page = 1, per_page = 5)
      sanitized_query = preprocess(query)
      return nil if sanitized_query.blank?
      search do
        fulltext sanitized_query
        with(:affiliate_id, affiliate.id)
        paginate :page => page, :per_page => per_page
      end
    end
  end
  
  def flickr_url
    "http://www.flickr.com/photos/#{self.owner}/#{self.flickr_id}/"
  end
    
  def update_with_raw_tags
    tag_string = get_raw_tags.collect{|tag| tag["raw"]}.join(",")
    update_attributes(:tags => tag_string.blank? ? nil : tag_string)
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