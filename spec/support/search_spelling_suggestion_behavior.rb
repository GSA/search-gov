shared_examples 'a search with spelling suggestion' do
  context 'when the query does not exist in the SuggestionBlock' do
    before { search.run }

    its(:spelling_suggestion) { should eq('electrocoagulation') }
  end

  context 'when the query exists in the SuggestionBlock' do
    before do
      SuggestionBlock.create!(query: 'electro coagulation')
      search.run
    end

    its(:spelling_suggestion) { should be_nil }
  end
end
