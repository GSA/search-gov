require 'spec_helper'

describe RtuQueryRawHumanArray do

  describe ".top_queries" do
    context 'when data is available' do
      let(:query_raw_human_array) { RtuQueryRawHumanArray.new('usagov', Date.current, Date.current, 5) }

      before do
        RtuTopQueries.stub(:new).with(anything, false).and_return mock(RtuTopQueries, top_n: [['query6', 55], ['query5', 54], ['query4', 14]])
        RtuTopQueries.stub(:new).with(anything, true).and_return mock(RtuTopQueries, top_n: [['query6', 53], ['query5', 50]])
      end

      it 'should return an array of [query, total, human] sorted by desc human' do
        query_raw_human_array.top_queries.should match_array([['query6', 55, 53], ['query5', 54, 50], ["query4", 14, 0]])
      end
    end

    context 'when start_date or end_date is nil' do
      let(:query_raw_human_array) { RtuQueryRawHumanArray.new('usagov', nil, nil, 5) }

      it "should return INSUFFICIENT_DATA" do
        query_raw_human_array.top_queries.should == RtuQueryRawHumanArray::INSUFFICIENT_DATA
      end
    end

    context "when there really is insufficient data" do
      let(:query_raw_human_array) { RtuQueryRawHumanArray.new('usagov', nil, nil, 5) }

      before do
        RtuTopQueries.stub(:new).and_return mock(RtuTopQueries, top_n: [])
      end

      it "should return INSUFFICIENT_DATA" do
        query_raw_human_array.top_queries.should == RtuQueryRawHumanArray::INSUFFICIENT_DATA
      end
    end
  end
end