# frozen_string_literal: true

describe 'RSS News Items', :js do
  let(:url) { '/admin/news_items' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'RSS News Items'
  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
