class FlickrProfile < ActiveRecord::Base
  belongs_to :affiliate
  has_many :flickr_photos, :dependent => :destroy

  validates_presence_of :url, :profile_type, :profile_id, :affiliate
  validates_inclusion_of :profile_type, :in => %w{user group}
  validates_uniqueness_of :url, :scope => :affiliate_id
  validate :is_flickr_url
  
  before_validation :normalize_url
  before_validation :lookup_profile_id, :on => :create
  
  after_create :queue_for_import
  
  EXTRA_FIELDS = "description, license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags, o_dims, views, media, path_alias, url_sq, url_t, url_s, url_q, url_m, url_n, url_z, url_c, url_l, url_o"

  def import_photos
    done_importing = false
    photos = get_photos
    if photos
      more_to_index = store_photos(photos)
      if photos.pages > 1 and more_to_index
        2.upto(photos.pages) do |page|
          photos = get_photos(page)
          if photos
            break unless store_photos(photos)
          end
        end
      end
    end
  end
  
  def get_photos(page = 1)
    self.profile_type == "user" ? (flickr.people.getPublicPhotos(:user_id => self.profile_id, :extras => EXTRA_FIELDS, :page => page) rescue nil) : (flickr.groups.pools.getPhotos(:group_id => self.profile_id, :extras => EXTRA_FIELDS, :page => page) rescue nil)
  end
    
  private
  
  def normalize_url
    self.url.strip! unless self.url.nil?
  end
  
  def lookup_profile_id
    unless self.profile_type and self.profile_id
      if self.url =~ /\/photos\// or self.url =~ /http:\/\/(www\.)?flickr.com\/[A-Za-z0-9]+$/
        self.profile_type = "user"
        begin
          self.profile_id = flickr.people.findByUsername(:username => self.url.split("/").last)["nsid"]
        rescue
          errors.add(:base, "We could not find the Flickr user that you specified.  Please modify the URL and try again.")
        end
      elsif self.url =~ /\/groups\//
        self.profile_type = "group"
        begin
          self.profile_id = flickr.groups.search(:text => self.url.split("/").last).first["nsid"]
        rescue
          errors.add(:base, "We could not find the Flickr group that you specified.  Please modify the URL and try again.")
        end
      end
    end
  end
  
  def is_flickr_url
    unless url =~ /http:\/\/(www\.)?flickr.com\/[A-Za-z0-9]+(\/)?$/ or
           url =~ /http:\/\/(www\.)?flickr.com\/photos\/[A-Za-z0-9]+(\/)?$/ or
           url =~ /http:\/\/(www\.)?flickr.com\/groups\/[A-Za-z0-9]+(\/)?$/
      errors.add(:url, "The URL you provided does not appear to be a valid Flickr user or Flickr group.  Please provide a URL for a valid Flickr user or Flickr group.")
      return false
    end
  end

  def store_photos(photos)
    photos.each do |photo|
      return false if self.flickr_photos.find_by_flickr_id(photo.to_hash["id"])
      self.flickr_photos.create(api_result_to_params(photo.to_hash))
    end
    true
  end
  
  def api_result_to_params(api_result)
    params = {}
    api_result.each do |key,value|
      case key
      when "lastupdate"
        params["last_update"] = value
      when "ispublic"
        params["is_public"] = value
      when "iconfarm"
        params["icon_farm"] = value
      when "pathalias"
        params["path_alias"] = value
      when "isfamily"
        params["is_family"] = value
      when "datetaken"
        params["date_taken"] = value
      when "dateupload"
        params["date_upload"] = Time.at(value.to_i)
      when "ownername"
        params["owner_name"] = value
      when "iconserver"
        params["icon_server"] = value
      when "id"
        params["flickr_id"] = value
      else
        params[key] = value
      end
    end
    params.reject{|k,v| FlickrPhoto.column_names.include?(k) == false }
  end
  
  def queue_for_import
    Resque.enqueue_with_priority(:high, FlickrProfileImporter, self.id)
  end
end