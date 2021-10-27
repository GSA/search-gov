# frozen_string_literal: true

describe 'Federal Register Documents', :js do
  let(:url) { '/admin/federal_register_documents' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Show], 'Federal Register Documents'
  it_behaves_like 'a Search'
end
