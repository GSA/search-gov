namespace :usasearch do
  namespace :calais_related_searches do

    desc "generate Calais-based related searches from popular DailyQueryStats queries from last week"
    task :compute, :needs => :environment do |t, args|
      CalaisRelatedSearch.populate_with_new_popular_terms
    end

  end
end