class FlickrPhoto < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :flickr_id, :affiliate
  validates_uniqueness_of :flickr_id, :scope => :affiliate_id
  EXTRA_FIELDS = "description, license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags, o_dims, views, media, path_alias, url_sq, url_t, url_s, url_q, url_m, url_n, url_z, url_c, url_l, url_o"
  
  class << self
    
    def import_photos(affiliate)
      if affiliate.flickr_url =~ /\/photos\//
        flickr_user = flickr.people.findByUsername(:username => affiliate.flickr_url.split("/").last)
        if flickr_user
          done_importing = false
          photos = flickr.people.getPublicPhotos(:user_id => flickr_user["nsid"], :extras => EXTRA_FIELDS)
          more_to_index = store_photos(photos, affiliate)
          if photos.pages > 1 and more_to_index
            2.upto(photos.pages) do |page|
              photos = flickr.people.getPublicPhotos(:user_id => flickr_user["nsid"], :extras => EXTRA_FIELDS, :page => page)
              break unless store_photos(photos, affiliate)
            end
          end
        end
      end
    end
    
    def store_photos(photos, affiliate)
      photos.each do |photo|
        return false if affiliate.flickr_photos.find_by_flickr_id(photo.to_hash["id"])
        affiliate.flickr_photos.create(api_result_to_params(photo.to_hash))
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
      params.reject{|k,v| %w{datetakengranularity views media_status media context isfriend}.include?(k) }
    end
  end
end
