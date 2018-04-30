require 'spec_helper'

describe BingV6ImageSearch, vcr: { re_record_interval: 2.months } do
  let(:image_search_params) do
    { offset: 20,
      limit: 10,
      query: 'agncy (site:nasa.gov)',
    }
  end
  let(:image_search) { described_class.new(image_search_params) }
  let(:search_response) { image_search.execute_query }


  it_behaves_like 'a Bing V6 search'
  it_behaves_like 'an image search'

  describe '#execute_query' do
    it 'sets the next_offset' do
      expect(search_response.next_offset).to be >= 30
    end

    it 'includes tracking information' do
      expect(search_response.tracking_information).to match(/[0-9A-F]{32}/)
    end
  end
end
