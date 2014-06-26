require 'spec_helper'

describe RtuQueryStat do

  describe ".most_popular_human_searches" do
    before do
      RtuTopQueries.stub(:new).and_return mock(RtuTopQueries, top_n: [['query6', 55], ['query5', 54]])
    end

    it 'should return an array of QueryCount sorted by desc times' do
      mphs = RtuQueryStat.most_popular_human_searches('usagov', Date.current, Date.current, 5)
      mphs.first.query.should == 'query6'
      mphs.last.query.should == 'query5'
      mphs.first.times.should == 55
      mphs.last.times.should == 54
    end

    context 'when start_date or end_date is nil' do
      it "should return INSUFFICIENT_DATA" do
        RtuQueryStat.most_popular_human_searches('usagov', nil, nil, 5).should == RtuQueryStat::INSUFFICIENT_DATA
      end
    end

    context "when there really is insufficient data" do
      before do
        RtuTopQueries.stub(:new).and_return mock(RtuTopQueries, top_n: [])
      end

      it "should return INSUFFICIENT_DATA" do
        RtuQueryStat.most_popular_human_searches('usagov', nil, nil, 5).should == RtuQueryStat::INSUFFICIENT_DATA
      end
    end
  end

  describe ".top_n_overall_human_searches" do
    before do
      RtuTopQueries.stub(:new).and_return mock(RtuTopQueries, top_n: [['query6', 55], ['query5', 54]])
    end

    it 'should return an array of query-count arrays sorted by desc times' do
      RtuQueryStat.top_n_overall_human_searches(1.week.ago, 50).should == [['query6', 55], ['query5', 54]]
    end
  end
end