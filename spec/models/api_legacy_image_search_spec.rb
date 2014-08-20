require 'spec_helper'

describe ApiLegacyImageSearch do
  fixtures :affiliates, :site_domains

  context 'when the affiliate has no Bing/Google results' do
    let(:non_affiliate) { affiliates(:non_existent_affiliate) }

    it 'returns empty results' do
      search = ApiLegacyImageSearch.new(query: 'unusual image', affiliate: non_affiliate)
      search.run
      search.results.should be_empty
      search.total.should == 0
    end

  end
end
