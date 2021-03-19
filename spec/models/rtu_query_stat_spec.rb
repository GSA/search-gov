require 'spec_helper'

describe RtuQueryStat do

  describe '.top_n_overall_human_searches' do
    subject(:top_n_overall_human_searches) do
      described_class.top_n_overall_human_searches(Date.new(2019, 11, 21), 50)
    end
    let(:rtu_top_queries) do
      instance_double(RtuTopQueries, top_n: [['query6', 55], ['query5', 54]])
    end

    before do
      expect(OverallTopNQuery).to receive(:new).
        with(Date.new(2019, 11, 21), field: 'params.query.raw', size: 50).and_call_original
      allow(RtuTopQueries).to receive(:new).and_return(rtu_top_queries)
    end

    it 'should return an array of query-count arrays sorted by desc times' do
      expect(top_n_overall_human_searches).to eq([['query6', 55], ['query5', 54]])
    end
  end
end
