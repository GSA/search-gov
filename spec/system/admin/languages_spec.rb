# frozen_string_literal: true

describe 'Languages', :js do
  let(:url) { '/admin/languages' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'Languages'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
