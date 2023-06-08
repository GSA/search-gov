# SRCH-3125: These (very basic) tests were added to maintain code coverage while still proceeding with the removal of
# deprecated Google search code. This file should be removed entirely when Azure/BingV5 is finally removed: SRCHAR-2913

describe ApiDocsSearch do
  subject(:search) do
    ApiAzureDocsSearch.new(search_params)
  end

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:collection) { document_collections(:usagov_docs) }
  let(:search_params) do
    { affiliate: affiliate,
      document_collection: collection,
      query: 'nutrition' }
  end

  describe '#new' do
    before do
      allow(AzureWebEngine).to receive(:new).
        with({ language: 'en',
               password: nil,
               query: 'nutrition (site:gov OR site:mil)' })
    end

    it 'initializes ApiDocsSearch' do
      expect(search.document_collection).to eq(collection)
    end
  end

  describe '#as_json' do
    before do
      search
    end

    it 'returns engine' do
      expect(search.as_json[:engine]).to eq('AWEB')
    end

    it 'returns a query' do
      expect(search.as_json[:query]).to eq('nutrition')
    end

    it 'returns docs offset and results' do
      expect(search.as_json[:docs]).to match(hash_including(:next_offset, :results))
    end
  end

  describe '#domains_scope_options' do
    before do
      search
    end

    it 'returns included and excluded domains' do
      expect(search.domains_scope_options).to match(hash_including(:included_domains, :excluded_domains))
    end
  end
end
