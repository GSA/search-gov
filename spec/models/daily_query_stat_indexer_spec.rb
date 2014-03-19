require 'spec_helper'

describe DailyQueryStatIndexer do
  fixtures :affiliates

  describe ".reindex_day(day)" do
    before do
      ResqueSpec.reset!
      DailyQueryStat.delete_all
      DailyQueryStat.create!(:day => "20110830", :query => "government", :times => 314, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      DailyQueryStat.create!(:day => "20110830", :query => "government", :times => 314, :affiliate => affiliates(:power_affiliate).name)
    end

    it "should enqueue reindexing for each trafficked affiliate for the day" do
      DailyQueryStatIndexer.reindex_day("20110830")
      DailyQueryStatIndexer.should have_queued("20110830", Affiliate::USAGOV_AFFILIATE_NAME)
      DailyQueryStatIndexer.should have_queued("20110830", affiliates(:power_affiliate).name)
    end
  end

  describe ".perform(day_string, affiliate_name)" do
    before do
      DailyQueryStat.delete_all
      DailyQueryStat.create!(:day => "20110830", :query => "government", :times => 314, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      @sample = DailyQueryStat.create!(:day => "20110830", :query => "government", :times => 314, :affiliate => affiliates(:power_affiliate).name)
      @indexer = mock(ElasticIndexer)
      ElasticIndexer.should_receive(:new).with("DailyQueryStat").and_return @indexer
    end

    it "should bulk remove the day's records from Elasticsearch for each affiliate and then index from the DB all the affiliate's records for a given day" do
      ElasticDailyQueryStat.should_receive(:delete_by_query).with(affiliate: @sample.affiliate, day: '2011-08-30')
      @indexer.should_receive(:index_batch).with([@sample])
      DailyQueryStatIndexer.perform(@sample.day.to_s, @sample.affiliate)
    end
  end
end