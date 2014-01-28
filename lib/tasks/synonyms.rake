namespace :usasearch do
  namespace :synonyms do

    desc "mine synonyms in parallel for SAYT suggestions updated for each site over last N days (defaults to 1 day)"
    task :mine, [:days_back] => [:environment] do |t, args|
      args.with_defaults(days_back: '1')
      days_back = args.days_back.to_i
      Affiliate.pluck(:id).each { |affiliate_id| Resque.enqueue(SynonymMiner, affiliate_id, days_back) }
    end
  end
end