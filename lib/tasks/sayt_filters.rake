namespace :usasearch do

  namespace :sayt_filters do
    desc "email popular query terms from last week that didn't become SaytSuggestions because of SaytFilter settings"
    task :filtered_popular_terms => :environment do
      top_5k_human_terms_from_last_week = RtuQueryStat.top_n_overall_human_searches(1.week.ago.to_date, 5000).collect(&:first)
      unfiltered = SaytFilter.filter(top_5k_human_terms_from_last_week)
      filtered_popular_terms = (top_5k_human_terms_from_last_week - unfiltered).reject { |t| t.match(/www/) }.sort
      Emailer.filtered_popular_terms_report(filtered_popular_terms).deliver_now unless filtered_popular_terms.empty?
    end
  end

end
