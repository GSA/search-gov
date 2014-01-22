namespace :usasearch do
  namespace :synonyms do

    desc "mine synonyms in parallel for top X queries for each site over last N months (defaults to 100 queries over last 2 months)"
    task :mine, [:words_per_affiliate, :months_back] => [:environment] do |t, args|
      args.with_defaults(words_per_affiliate: '100', months_back: '2')
      words_per_affiliate, months_back = args.words_per_affiliate.to_i, args.months_back.to_i
      Affiliate.pluck(:id).each { |affiliate_id| Resque.enqueue(SynonymMiner, affiliate_id, words_per_affiliate, months_back) }
    end
  end
end