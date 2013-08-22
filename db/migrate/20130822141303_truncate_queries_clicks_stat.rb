class TruncateQueriesClicksStat < ActiveRecord::Migration
  def up
    execute %q{TRUNCATE queries_clicks_stats}
  end

  def down
  end
end
