# frozen_string_literal: true

describe 'Collections', :js do
  let(:url) { '/admin/document_collections' }
  let(:downloaded_csv) { 'document_collections.csv' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'Collections'
  it_behaves_like 'a CSV export'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
