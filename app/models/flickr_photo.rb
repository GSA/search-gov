class FlickrPhoto < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :flickr_id, :affiliate
  validates_uniqueness_of :flickr_id, :scope => :affiliate_id
  EXTRA_FIELDS = "description, license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags, o_dims, views, media, path_alias, url_sq, url_t, url_s, url_q, url_m, url_n, url_z, url_c, url_l, url_o"
  
  searchable do
    text :title
    text :description
    text :tag do |flickr_photo|
      flickr_photo.tags.split(",") unless flickr_photo.tags.blank?
    end
    integer :affiliate_id
  end
  
  def flickr_url
    "http://www.flickr.com/photos/#{self.owner}/#{self.flickr_id}/"
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
    
    def import_photos(affiliate)
      unless affiliate.flickr_url.blank?
        flickr_id = get_flickr_id_for_user_or_group(affiliate.flickr_url)
        if flickr_id
          done_importing = false
          photos = get_photos_for_user_or_group(flickr_id, {:extras => EXTRA_FIELDS})
          if photos
            more_to_index = store_photos(photos, affiliate)
            if photos.pages > 1 and more_to_index
              2.upto(photos.pages) do |page|
                photos = get_photos_for_user_or_group(flickr_id, {:extras => EXTRA_FIELDS, :page => page})
                if photos
                  break unless store_photos(photos, affiliate)
                end
              end
            end
          end
        end
      end
    end
    
    def get_flickr_id_for_user_or_group(flickr_url)
      if flickr_url =~ /\/photos\//
        return {:flickr_id_type => :user_id, :flickr_id_value => flickr.people.findByUsername(:username => flickr_url.split("/").last)} rescue nil
      elsif flickr_url =~ /\/groups\//
        groups_search = flickr.groups.search(:text => flickr_url.split("/").last) rescue nil
        return {:flickr_id_type => :group_id, :flickr_id_value => groups_search.first} if groups_search and groups_search.size == 1
      end
      return nil
    end
    
    def get_photos_for_user_or_group(flickr_id_hash, other_params)
      if flickr_id_hash[:flickr_id_type] == :user_id
        return flickr.people.getPublicPhotos({:user_id => flickr_id_hash[:flickr_id_value]["nsid"]}.merge(other_params)) rescue nil
      elsif flickr_id_hash[:flickr_id_type] == :group_id
        return flickr.groups.pools.getPhotos({:group_id => flickr_id_hash[:flickr_id_value]["nsid"]}.merge(other_params)) rescue nil
      end
      return nil
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
      if params["tags"].blank?
        params["tags"] = nil
      else
        params["tags"] = ""
        photo_info = flickr.photos.getInfo(:photo_id => params["flickr_id"]) rescue nil
        unless photo_info.nil? or photo_info.empty?
          photo_info["tags"].each do |tag|
            params["tags"] << "#{tag["raw"]},"
          end
        end
        params["tags"].chop!
      end
      params.reject{|k,v| FlickrPhoto.column_names.include?(k) == false }
    end
  end
end
