class DailyQueryStatIndexer
  extend Resque::Plugins::Priority
  @queue = :primary
  DEFAULT_BATCH_SIZE = 100000

  class << self
    def reindex_day(day)
      DailyQueryStat.where(day: day).group(:affiliate).order("sum_times desc").sum(:times).each do |dqs|
        Resque.enqueue(self, day, dqs[0])
      end
    end

    def perform(day, affiliate_name)
      ElasticDailyQueryStat.delete_by_query(affiliate: affiliate_name, day: day)
      indexer = ElasticIndexer.new(DailyQueryStat.to_s)
      DailyQueryStat.where(day: day, affiliate: affiliate_name).find_in_batches(batch_size: DEFAULT_BATCH_SIZE) do |records|
        indexer.index_batch(records)
      end
    end
  end
end