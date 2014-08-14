class FlickrProfile < ActiveRecord::Base
  attr_readonly :url, :profile_type, :profile_id
  belongs_to :affiliate
  has_many :flickr_photos

  before_validation :assign_profile_type_and_profile_id,
                    on: :create,
                    if: :url?

  validates_presence_of :affiliate_id, :url
  validates_presence_of :profile_type, :profile_id,
                        on: :create,
                        if: :url?,
                        message: 'invalid Flickr URL'
  validates_inclusion_of :profile_type,
                         on: :create,
                         in: %w{user group},
                         if: :profile_type?
  validates_uniqueness_of :profile_id,
                          on: :create,
                          scope: [:affiliate_id, :profile_type],
                          case_sensitive: false,
                          message: 'has already been added',
                          if: Proc.new { |fp| fp.affiliate_id? && fp.profile_type? && fp.profile_id? }

  after_create :queue_for_import
  after_create :notify_oasis
  before_destroy :destroy_flickr_photos
  scope :users, where(profile_type: 'user')
  scope :groups, where(profile_type: 'group')

  EXTRA_FIELDS = "description, license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags, o_dims, views, media, path_alias, url_sq, url_t, url_s, url_q, url_m, url_n, url_z, url_c, url_l, url_o"

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
    case profile_type
      when 'user' then get_user_photos page
      when 'group' then get_group_photos page
    end
  end

  private

  def assign_profile_type_and_profile_id
    NormalizeUrl.new :url
    detect_profile_type
    lookup_and_assign_profile_id if profile_type.present?
  end

  def detect_profile_type
    self.profile_type =
        case url
          when %r[/photos/] then 'user'
          when %r[/groups/] then 'group'
        end
  end

  def lookup_and_assign_profile_id
    lookup_method = "lookup#{profile_type.capitalize}"
    self.profile_id = flickr.urls.send(lookup_method, url: url)['id'] rescue nil
  end

  def get_user_photos(page)
    flickr.people.getPublicPhotos(user_id: self.profile_id, extras: EXTRA_FIELDS, page: page) rescue nil
  end

  def get_group_photos(page)
    flickr.groups.pools.getPhotos(group_id: self.profile_id, extras: EXTRA_FIELDS, page: page) rescue nil
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

  def destroy_flickr_photos
    flickr_photos.find_in_batches(batch_size: 10000) do |g|
      flickr_photo_ids = g.map(&:id)
      ElasticFlickrPhoto.delete flickr_photo_ids
      FlickrPhoto.delete_all(['id IN (?)', flickr_photo_ids])
    end
  end

  def notify_oasis
    Oasis.subscribe_to_flickr(self.profile_id, self.url.sub(/\/$/,'').split('/').last, self.profile_type)
  end

end
