class FlickrProfile < ActiveRecord::Base
  attr_readonly :url
  belongs_to :affiliate
  has_many :flickr_photos, :dependent => :destroy

  before_validation NormalizeUrl.new(:url), on: :create
  validates_format_of :url,
                      :with => %r{^http:\/\/(www\.)?flickr\.com\/(groups|photos)\/[A-Za-z0-9@]+(\/)?$},
                      :message => 'must be a valid Flickr user or Flickr group.'
  validates_presence_of :affiliate_id
  validate :must_have_profile_id, :on => :create, :if => :has_valid_url?
  validates_uniqueness_of :profile_id,
                          scope: [:affiliate_id, :profile_type],
                          case_sensitive: false,
                          message: 'has already been added',
                          if: :has_valid_url?
  validates_presence_of :profile_id, :profile_type, :if => :has_valid_url?
  validates_inclusion_of :profile_type, :in => %w{user group}, :if => :has_valid_url?

  after_create :queue_for_import

  EXTRA_FIELDS = "description, license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags, o_dims, views, media, path_alias, url_sq, url_t, url_s, url_q, url_m, url_n, url_z, url_c, url_l, url_o"

  def recent
    self.flickr_photos.recent
  end

  def link_to_profile
    self.url
  end

  def import_photos
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

  def must_have_profile_id
    unless self.profile_type and self.profile_id
      if self.url =~ /\/photos\//
        self.profile_type = "user"
        begin
          self.profile_id = flickr.urls.lookupUser(:url => self.url)["id"]
        rescue
          errors.add(:base, "We could not find the Flickr user that you specified.  Please modify the URL and try again.")
        end
      elsif self.url =~ /\/groups\//
        self.profile_type = "group"
        begin
          self.profile_id = flickr.urls.lookupGroup(:url => self.url)["id"]
        rescue
          errors.add(:base, "We could not find the Flickr group that you specified.  Please modify the URL and try again.")
        end
      end
    end
  end

  def has_valid_url?
    url =~ /http:\/\/(www\.)?flickr\.com\/(groups|photos)\/[A-Za-z0-9]+(\/)?$/
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
