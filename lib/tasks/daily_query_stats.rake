namespace :usasearch do

  namespace :daily_query_stats do
    desc "tell Solr to index the collection of most-recently-added DailyQueryStats (ideally yesterday's)"
    task :index_most_recent_day_stats_in_solr => :environment do
      Sunspot.index(DailyQueryStat.find_all_by_day(DailyQueryStat.most_recent_populated_date))
    end
  end

end