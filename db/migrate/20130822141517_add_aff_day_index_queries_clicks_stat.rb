class AddAffDayIndexQueriesClicksStat < ActiveRecord::Migration
  def change
    add_index(:queries_clicks_stats, [:affiliate, :day])
  end
end
