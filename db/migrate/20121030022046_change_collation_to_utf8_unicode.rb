class ChangeCollationToUtf8Unicode < ActiveRecord::Migration
  def up
    execute %{alter table queries_clicks_stats convert to character set utf8 collate utf8_general_ci;}
    execute %{alter table daily_query_noresults_stats convert to character set utf8 collate utf8_general_ci;}
  end

  def down
  end
end
