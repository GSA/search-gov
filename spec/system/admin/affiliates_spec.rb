# frozen_string_literal: true

describe 'Affiliates', :js do
  let(:url) { '/admin/affiliates' }
  let(:downloaded_csv) { 'affiliates.csv' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Show], 'Sites'
  it_behaves_like 'a CSV export'
  it_behaves_like 'a Search'

  describe 'Analytics' do
    include_context 'log in super admin'

    before do
      visit(url)
      first('td.actions').click_link('Analytics')
    end

    it 'redirects to the affiliate analytics page for the affiliate id passed' do
      expect(page).to have_text('Queries')
    end
  end
end
