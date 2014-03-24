class CreateFlickrIndex < ActiveRecord::Migration
  def up
    ElasticFlickrPhoto.create_index unless ElasticFlickrPhoto.index_exists?
  end

  def down
    ElasticFlickrPhoto.delete_index if ElasticFlickrPhoto.index_exists?
  end
end
