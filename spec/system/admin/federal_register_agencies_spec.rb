# frozen_string_literal: true

describe 'Federal Register Agencies', :js do
  let(:url) { '/admin/federal_register_agencies' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Show], 'Federal Register Agencies'
  it_behaves_like 'a Search'
end
