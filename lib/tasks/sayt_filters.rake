namespace :usasearch do

  namespace :sayt_filters do
    desc "email popular query terms from last week that didn't become SaytSuggestions because of SaytFilter settings"
    task :filtered_popular_terms => :environment do
      top_terms = DailyQueryStat.sum(:times,
                                :group => :query,
                                :conditions => ['day > ?', Date.current - 7],
                                :order => "sum_times desc",
                                :limit => 5000).collect(&:first)
      unfiltered = SaytFilter.filter(top_terms)
      filtered_popular_terms = (top_terms - unfiltered).reject{|t|t.match(/www/)}.sort
      Emailer.filtered_popular_terms_report(filtered_popular_terms).deliver unless filtered_popular_terms.empty?
    end
  end

end