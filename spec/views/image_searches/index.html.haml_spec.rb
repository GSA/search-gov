# frozen_string_literal: true

describe 'image_searches/index' do
  let(:affiliate) { affiliates(:usagov_affiliate) }

  context 'when there are 5 Oasis pics' do
    before do
      assign(:affiliate, affiliate)
      results = (1..5).map do |i|
        Hashie::Mash::Rash.new(title: "title #{i}", url: "http://flickr/#{i}", display_url: "http://flickr/#{i}",
                         thumbnail: { url: "http://flickr/thumbnail/#{i}" })
      end
      allow(results).to receive(:total_pages).and_return(1)
      @search = double(ImageSearch, commercial_results?: false, query: 'test', affiliate: affiliate, module_tag: 'OASIS',
                       queried_at_seconds: 1_271_978_870, results: results, startrecord: 1, total: 5, per_page: 20,
                       page: 1, spelling_suggestion: nil)
      assign(:search, @search)
      assign(:search_params, { affiliate: affiliate.name, query: 'test' })
    end

    it 'should show 5 Oasis pics' do
      selector = '#results .result.image'
      render
      expect(rendered).to have_selector(selector, count: 5)
    end

    it 'should be Powered by Search.gov' do
      render
      expect(rendered).to have_content('Powered by Search.gov')
    end
  end

  context 'when there are 20 Oasis pics' do
    before do
      assign(:affiliate, affiliate)
      results = (1..20).map do |i|
        Hashie::Mash::Rash.new(title: "title #{i}", url: "http://flickr/#{i}", display_url: "http://flickr/#{i}",
                         thumbnail: { url: "http://flickr/thumbnail/#{i}" })
      end
      allow(results).to receive(:total_pages).and_return(1)
      @search = double(ImageSearch, commercial_results?: false, query: 'test', affiliate: affiliate, module_tag: 'OASIS',
                       queried_at_seconds: 1_271_978_870, results: results, startrecord: 1, total: 20, per_page: 20,
                       page: 1, spelling_suggestion: nil)
      allow(ImageSearch).to receive(:===).and_return true
      assign(:search, @search)
      assign(:search_params, { affiliate: affiliate.name, query: 'test' })
    end

    it 'should show 20 Oasis pics' do
      selector = '#results .result.image'
      render
      expect(rendered).to have_selector(selector, count: 20)
    end

    it 'should be Powered by SearchGov' do
      render
      expect(rendered).to have_content('Powered by SearchGov')
    end
  end

  context 'when there are no Oasis pics' do
    before do
      assign(:affiliate, affiliate)
      @search = double(ImageSearch, query: 'test', affiliate: affiliate, error_message: nil, module_tag: nil,
                       queried_at_seconds: 1_271_978_870, results: [], startrecord: 0, total: 0, per_page: 20,
                       page: 0, spelling_suggestion: nil)
      assign(:search, @search)
      assign(:search_params, { affiliate: affiliate.name, query: 'test' })
    end

    it 'should say no results found' do
      render
      expect(rendered).to have_content('no results found')
    end
  end
end
