# frozen_string_literal: true

describe 'Blocked Suggestions', :js do
  let(:url) { '/admin/suggestion_blocks' }

  it_behaves_like 'a page restricted to super admins'

  context 'when there is a blocked suggestion' do
    before { SuggestionBlock.create(query: 'ferd') }

    it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'Query Terms Blocked'
  end

  it_behaves_like 'a Search'
  it_behaves_like 'a Create New'
end
