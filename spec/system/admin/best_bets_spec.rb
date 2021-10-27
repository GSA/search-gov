# frozen_string_literal: true

describe 'Best Bets', :js do
  let(:url) { '/admin/affiliate_boosted_contents' }
  let(:downloaded_csv) { 'affiliate_boosted_contents.csv' }

  it_behaves_like 'a page restricted to super admins'
  it_behaves_like 'an ActiveScaffold page', %w[Delete Show], 'Best Bets: Text'
  it_behaves_like 'a CSV export'
  it_behaves_like 'a Search'
end
