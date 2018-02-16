require 'spec_helper'

describe Searches::FiltersHelper do
  describe '#results_count_html' do
    it 'returns formatted results count' do
      search = double(NewsSearch, total: 1555888)
      allow(search).to receive_message_chain(:results, :present?) { true }
      expect(helper.results_count_html(search)).to have_content('1,555,888 RESULTS')
    end
  end
end
