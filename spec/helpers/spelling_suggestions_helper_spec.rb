require 'spec_helper'

describe SpellingSuggestionsHelper do
  let(:affiliate) { mock_model(Affiliate, name: 'usasearch') }
  let(:search) do
    double('Search',
         affiliate: affiliate,
         query: '<initialquery>',
         queried_at_seconds: Time.current.to_i,
         spelling_suggestion: '<suggestion>')
  end

  describe '#spelling_suggestion(search, search_options)' do
    it 'returns HTML escaped output containing the initial query with site_limits and the suggestion' do
      html = helper.spelling_suggestion(search, site_limits: 'blogs.cdc.gov/niosh-science-blog www.cdc.gov/niosh')
      expect(html).to have_link('<suggestion>',
                                href: '/search?affiliate=usasearch&query=%3Csuggestion%3E&sitelimit=blogs.cdc.gov%2Fniosh-science-blog+www.cdc.gov%2Fniosh')
      expect(html).to have_content('Showing results for <suggestion>')
      expect(html).to have_content('Search instead for <initialquery>')
    end
  end
end
