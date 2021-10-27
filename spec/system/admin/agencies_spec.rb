# frozen_string_literal: true

describe 'Agencies', :js do
  let(:url) { '/admin/agencies' }
  let(:downloaded_csv) { 'agencies.csv' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'Agencies'
  it_behaves_like 'a CSV export'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
