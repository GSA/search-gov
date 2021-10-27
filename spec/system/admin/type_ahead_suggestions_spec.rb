# frozen_string_literal: true

describe 'Type Ahead Suggestions', :js do
  let(:url) { '/admin/sayt_suggestions' }

  it_behaves_like 'a page restricted to super admins'

  context 'when there is a sayt suggestion' do
    before do
      SaytSuggestion.create!(phrase: 'Something strange',
                             affiliate: Affiliate.first)
    end

    it_behaves_like 'an ActiveScaffold page', %w[Edit Delete Show], 'Type Ahead Suggestions'
  end

  it_behaves_like 'a Search'
end
