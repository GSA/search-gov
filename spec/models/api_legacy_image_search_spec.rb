require 'spec_helper'

describe ApiLegacyImageSearch do
  fixtures :affiliates, :site_domains

  context 'when the affiliate has no Bing/Google results' do
    let(:non_affiliate) { affiliates(:non_existent_affiliate) }

    it 'returns empty results' do
      search = described_class.new(query: 'unusual image', affiliate: non_affiliate)
      search.run
      expect(search.results).to be_empty
      expect(search.total).to eq(0)
    end

  end
end
