require 'spec_helper'

describe Searches::FiltersHelper do
  describe '#results_count_html' do
    it 'returns formatted results count' do
      search = instance_double(NewsSearch, total: 1_555_888)
      allow(search).to receive_message_chain(:results, :present) { true }
      expect(helper.results_count_html(search)).to have_content('1,555,888 results')
    end

    context 'when there is only one result' do
      let(:search) { instance_double(Search, total: 1) }

      it 'does not pluralize the result' do
        allow(search).to receive_message_chain(:results, :present) { true }
        expect(helper.results_count_html(search)).to have_content('1 result')
      end
    end
  end
end
