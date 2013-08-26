namespace :usasearch do

  namespace :daily_query_stats do
    desc "tell Solr to clean and reindex one day's worth of DailyQueryStats"
    task :reindex_day, [:day] => [:environment] do |t, args|
      day = args[:day]
      if day.blank?
        Rails.logger.error("usage: rake usasearch:daily_query_stats:reindex_day[yyyy-mm-dd]")
      else
        DailyQueryStat.reindex_day(day)
      end
    end

    desc 'tell Solr to prune DailyQueryStats more than X months old'
    task :prune_before, [:months_back] => [:environment] do |t,args|
      DailyQueryStat.prune_before(args[:months_back].to_i.months.ago.beginning_of_month.beginning_of_day)
    end
  end

end