# frozen_string_literal: true

describe 'Type Ahead Filters', :js do
  let(:url) { '/admin/sayt_filters' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'Type Ahead Filters'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
