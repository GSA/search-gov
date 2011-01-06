class AddPopularImageQuery < ActiveRecord::Migration
  def self.up
    create_table :popular_image_queries do |t|
      t.string :query
      t.timestamps
    end
    add_index :popular_image_queries, :query, :unique => true

    [
      "honda",
      "accessibility",
      "clouds",
      "aloe",
      "rocks",
      "marilyn monroe",
      "tornado",
      "a glove",
      "obama",
      "The Rolling Stones",
      "unemployment benefits",
      "chicago",
      "unemployment rate",
      "ajin",
      "seattle",
      "christmas",
      "black powder",
      "car",
      "wetlands",
      "mountain howitzer",
      "hurricanes",
      "National Air and Space Museum",
      "energy",
      "tornadoes",
      "santa claus",
      "hurricane katrina",
      "water",
      "wikileaks",
      "liu xiaobo",
      "snowflake",
      "salmon",
      "sun bathing",
      "female",
      "hurricane",
      "meteor shower",
      "moon",
      "Kawaihae",
      "cheetah",
      ".416 barrett round",
      "girl",
      "femtosecond",
      "fog",
      "shotgun",
      "Rear View Cameras",
      "pirates",
      "sun",
      "female officer",
      "fireworks store",
      "bike",
      "army food",
      "blizzard",
      "thompson gun",
      "snow",
      "homeless",
      "light",
      "coca cola",
      "breast self-examination",
      "money",
      "dragon",
      "MIAMIBEACH",
      "long range reconnaissance patrol",
      "civil war reenactor",
      "hawaii",
      "santa hat",
      "GAY PRIDE",
      "moonshine",
      "baby",
      "woman",
      "actress and model",
      "css hunley",
      "beaches",
      "worst ice storm",
      "Arsenic-Based Life",
      "thunderstorms",
      "fire",
      "uss tennessee",
      "chemistry",
      "red rock canyon nevada"
    ].each do |query|
      PopularImageQuery.create(:query => query)
    end

  end

  def self.down
    drop_table :popular_image_queries
  end

end
