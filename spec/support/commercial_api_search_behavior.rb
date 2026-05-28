shared_examples 'a commercial API search' do
  describe '#new' do
    context 'when advanced parameters are included' do
      let(:search_params) do
        { affiliate: affiliate,
          access_key: 'usagov_key',
          format: 'json',
          api_key: 'myawesomekey',
          query: 'testing',
          query_not: 'excluded',
          query_or: 'alternative',
          query_quote: 'barack obama',
          filetype: 'pdf',
          filter: '2'
        }
      end
      let(:search) { described_class.new search_params }

      it 'builds the query from the advanced parameters' do
        expect(search.query).to eq 'testing "barack obama" -excluded (alternative)'
      end
    end
  end
end

shared_examples 'a commercial API search as_json' do
end
