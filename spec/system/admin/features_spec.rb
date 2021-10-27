# frozen_string_literal: true

describe 'Features', :js do
  let(:url) { '/admin/features' }
  let(:downloaded_csv) { 'features.csv' }

  it_behaves_like 'a page restricted to super admins'

  it_behaves_like 'a CSV export'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'

  context 'when there is a feature' do
    before do
      Feature.create(display_name: 'display',
                     internal_name: 'internal')
    end

    it_behaves_like 'an ActiveScaffold page', %w[Edit Show], 'Features'
  end
end
