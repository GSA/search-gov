namespace :usasearch do
  namespace :calais_related_searches do

    desc "generate Calais-based related searches from popular DailyQueryStats queries from last week"
    task :compute, :needs => :environment do |t, args|
      CalaisRelatedSearch.populate_with_new_popular_terms
    end

    desc "regenerate related terms for oldest CalaisRelatedSearch entries"
    task :refresh, :needs => :environment do |t, args|
      CalaisRelatedSearch.refresh_stalest_entries
    end

    desc "prune CalaisRelatedSearch entries that lead to no search results"
    task :prune_dead_ends => :environment do
      CalaisRelatedSearch.prune_dead_ends
    end

  end
end