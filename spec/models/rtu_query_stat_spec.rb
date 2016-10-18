require 'spec_helper'

describe RtuQueryStat do

  describe ".top_n_overall_human_searches" do
    before do
      RtuTopQueries.stub(:new).and_return double(RtuTopQueries, top_n: [['query6', 55], ['query5', 54]])
    end

    it 'should return an array of query-count arrays sorted by desc times' do
      RtuQueryStat.top_n_overall_human_searches(1.week.ago, 50).should == [['query6', 55], ['query5', 54]]
    end
  end
end
