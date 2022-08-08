class ChangeDataTypeForNewsItemProperties < ActiveRecord::Migration[6.1]
  def up
    # create a faux model to attempting to JSON parse still-YAML content
    faux_news = Class.new ActiveRecord::Base
    faux_news.table_name = 'news_items'

    faux_news.select([:id, :properties]).find_in_batches do |news|
      news.each do |item|
        begin
          next if item.properties.nil?

          item.properties = YAML.load(item.properties).to_json
          item.save!

        rescue Exception => e
          puts "Could not fix news item #{item.id} for #{e.message}"
        end
      end
    end

    change_column :news_items, :properties, :json
  end

  def down
    change_column :news_items, :properties, :text
  end
end
