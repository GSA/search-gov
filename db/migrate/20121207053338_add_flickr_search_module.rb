class AddFlickrSearchModule < ActiveRecord::Migration
  def up
    SearchModule.create!(tag: 'FLICKR', display_name: 'Flickr Image Results')
  end

  def down
    SearchModule.find_by_tag('FLICKR').destroy
  end
end
