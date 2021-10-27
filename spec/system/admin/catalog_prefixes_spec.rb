# frozen_string_literal: true

describe 'Customer Whitelist', :js do
  let(:url) { '/admin/catalog_prefixes' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'Customer Catalog Prefix Whitelist'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
