require 'spec_helper'

describe Searches::FiltersHelper do
  describe '#results_count_html' do
    it 'returns formatted results count' do
      search = double(NewsSearch, total: 1555888)
      search.stub_chain(:results, :present?) { true }
      expect(helper.results_count_html(search)).to contain('1,555,888 RESULTS')
    end
  end
end
