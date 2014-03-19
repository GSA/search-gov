require 'spec_helper'

describe ElasticDailyQueryStat do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    ElasticDailyQueryStat.recreate_index
    affiliate.daily_query_stats.delete_all
  end

  describe ".search_for" do
    describe "results structure" do
      context 'when there are results' do
        before do
          DailyQueryStat.create!(affiliate: 'foo', query: 'hi suggest me', times: 30, day: Date.current)
          @dqs = DailyQueryStat.create!(affiliate: affiliate.name, query: 'suggest me too', times: 29, day: Date.current)
          DailyQueryStat.create!(affiliate: 'bar', query: 'suggest me three suggests', times: 28, day: Date.current)
          ElasticDailyQueryStat.commit
        end

        it 'should return ids in an easy to access structure' do
          search = ElasticDailyQueryStat.search_for(q: 'suggests', affiliate: affiliate.name, start_date: Date.yesterday, end_date: Date.current)
          search.total.should == 1
          search.ids.size.should == 1
          search.ids.first.should == @dqs.id
        end
      end
    end
  end

  describe "filters" do
    context 'when there are matches across a date range' do
      before do
        affiliate.daily_query_stats.create!(query: 'yesterday term date filter', times: 29, day: Date.yesterday)
        affiliate.daily_query_stats.create!(query: 'today term date filter', times: 29, day: Date.current)
        affiliate.daily_query_stats.create!(query: 'tomorrow term date filter', times: 29, day: Date.tomorrow)
        ElasticDailyQueryStat.commit
      end

      it "should return only the matches for a given date" do
        search = ElasticDailyQueryStat.search_for(q: 'date filter', affiliate: affiliate.name, start_date: Date.current, end_date: Date.current)
        search.total.should == 1
      end
    end

    context 'when there are matches across affiliates' do
      let(:other_affiliate) { affiliates(:power_affiliate) }

      before do
        affiliate.daily_query_stats.create!(query: 'today term date filter', times: 29, day: Date.current)
        other_affiliate.daily_query_stats.create!(query: 'today term date filter', times: 29, day: Date.current)
        ElasticDailyQueryStat.commit
      end

      it "should return only matches for the given affiliate" do
        search = ElasticDailyQueryStat.search_for(q: 'date filter', affiliate: affiliate.name, start_date: Date.current, end_date: Date.current)
        search.total.should == 1
        search = ElasticDailyQueryStat.search_for(q: 'date filter', affiliate: other_affiliate.name, start_date: Date.current, end_date: Date.current)
        search.total.should == 1
      end
    end
  end

  describe "recall" do
    before do
      affiliate.daily_query_stats.create!(query: 'internal internship symbolic ocean organ computing powered engine', times: 29, day: Date.current)
      ElasticDailyQueryStat.commit
    end

    describe "phrase" do
      it 'should be case insentitive' do
        ElasticDailyQueryStat.search_for(q: 'INTERNAL', affiliate: affiliate.name, start_date: Date.current, end_date: Date.current).total.should == 1
      end

      it 'should do aggressive snowball stemming' do
        %w{powerful engineering computers intern organics symbolizes organic oceanic}.each do |term|
          ElasticDailyQueryStat.search_for(q: term, affiliate: affiliate.name, start_date: Date.current, end_date: Date.current).total.should == 1
        end
      end
    end
  end

end