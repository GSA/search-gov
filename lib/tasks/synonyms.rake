namespace :usasearch do
  namespace :synonyms do

    desc "mine synonyms in parallel for most popular SAYT suggestions for each site"
    task :mine, [:min_popularity] => [:environment] do |t, args|
      args.with_defaults(min_popularity: '10')
      min_popularity = args.min_popularity.to_i
      Affiliate.pluck(:id).each { |affiliate_id| Resque.enqueue(SynonymMiner, affiliate_id, min_popularity) }
    end

    desc "combine any overlapping synonyms per locale"
    task group_overlapping_synonyms: :environment do
      Synonym.pluck(:locale).uniq.each do |locale|
        %w{Approved Candidate}.each do |status|
          Synonym.group_overlapping_synonyms(locale, status)
        end
      end
    end
  end
end