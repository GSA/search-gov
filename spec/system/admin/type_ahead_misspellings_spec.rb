# frozen_string_literal: true

describe 'Type Ahead Misspellings', :js do
  let(:url) { '/admin/misspellings' }

  it_behaves_like 'a page restricted to super admins'

  context 'when there is a misspelling entry' do
    before { Misspelling.create(wrong: 'rong', rite: 'write') }

    it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'Type Ahead Misspellings'
  end

  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
