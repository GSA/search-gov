require 'spec_helper'

describe RtuQueryStat do

  describe ".top_n_overall_human_searches" do
    before do
      allow(RtuTopQueries).to receive(:new).and_return double(RtuTopQueries, top_n: [['query6', 55], ['query5', 54]])
    end

    it 'should return an array of query-count arrays sorted by desc times' do
      expect(RtuQueryStat.top_n_overall_human_searches(1.week.ago, 50)).to eq([['query6', 55], ['query5', 54]])
    end
  end
end
