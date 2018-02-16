require 'spec_helper'

describe 'shared/_affiliate_vertical_navigation.html.haml' do
  context 'when the NewsSearch facets is nil' do
    before do
      affiliate = mock_model(Affiliate, is_time_filter_enabled?: true)
      assign :affiliate, affiliate

      search = double('search', query: 'gov', aggregations: nil)
      expect(search).to receive(:kind_of?).with(NewsSearch).and_return true
      assign :search, search

      allow(view).to receive :render_navigations
    end

    it 'should render the partial without error' do
      render
      expect(rendered).to match(/var original_query/)
    end
  end
end
