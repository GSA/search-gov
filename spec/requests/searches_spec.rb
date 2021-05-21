# frozen_string_literal: true

describe SearchesController do
  let(:affiliate) { affiliates(:basic_affiliate) }

  context '#news' do
    context 'when the request is from a mobile device' do
      before do
        iphone_user_agent = 'Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3'
        get '/search/news', params:  { query: 'element',
                                       affiliate: affiliate.name,
                                       channel: rss_feeds(:white_house_blog).id },
                            headers: { 'HTTP_USER_AGENT' => iphone_user_agent }
      end

      it 'sets the format to mobile' do
        expect(request.format.to_sym).to eq(:mobile)
      end

      it 'responds sucessfully' do
        expect(response.status).to eq(200)
      end
    end
  end

  context '#docs' do
    context 'when the request is from a mobile device' do
      before do
        iphone_user_agent = 'Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3'
        get '/search/docs', params: { query: 'pdf',
                                      affiliate: affiliate.name },
                            headers:  { 'HTTP_USER_AGENT' => iphone_user_agent }
      end

      it 'sets the format to mobile' do
        expect(request.format.to_sym).to eq(:mobile)
      end

      it 'responds with success' do
        expect(response.status).to eq(200)
      end
    end
  end

  context 'when searching via the legacy video news path' do
    let(:video_search_params) do
      { query: 'element', affiliate: affiliate.name }
    end

    before do
      get '/search/news/videos', params: video_search_params
    end

    it { is_expected.to redirect_to search_url(video_search_params) }
  end
end
