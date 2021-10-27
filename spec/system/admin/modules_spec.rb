# frozen_string_literal: true

describe 'Modules', :js do
  let(:url) { '/admin/search_modules' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'Modules'
end
