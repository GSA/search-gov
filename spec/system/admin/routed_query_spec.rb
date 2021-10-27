# frozen_string_literal: true

describe 'RoutedQueries', :js do
  let(:url) { '/admin/routed_queries' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'RoutedQueries'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
