class NormalizeTwitterScreenNames < ActiveRecord::Migration
  def up
    execute("UPDATE twitter_profiles SET screen_name = TRIM(LEADING '@' FROM screen_name)")
  end

  def down
  end
end
