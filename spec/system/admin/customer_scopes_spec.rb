# frozen_string_literal: true

describe 'Customer Scopes', :js do
  let(:url) { '/admin/affiliate_scopes' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Show], 'Customer Scopes'
  it_behaves_like 'a Search'
end
