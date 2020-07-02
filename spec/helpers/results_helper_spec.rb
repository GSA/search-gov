# frozen_string_literal: true

describe ResultsHelper do
  describe '#search_data' do
    let(:search) do
      instance_double('search',
             affiliate: affiliates(:basic_affiliate),
             query: 'rutabaga')
    end

    subject(:search_data) { helper.search_data(search, 'i14y') }

    it 'adds data attributes to #search needed for click tracking' do
      expected_output = {
        data: {
          affiliate: 'nps.gov',
          vertical: 'i14y',
          query: 'rutabaga'
        }
      }

      expect(search_data).to eq expected_output
    end
  end

  describe '#link_to_result_title' do
    subject(:link_to_result_title) { helper.link_to_result_title('test title', 'https://test.gov', '2', 'BOOS') }

    it 'makes a link with the added data-click attribute' do
      expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;,'\
                        '&quot;module_code&quot;:&quot;BOOS&quot;}"'\
                        ' href="https://test.gov">test title</a>'

      expect(link_to_result_title).to eq expected_output
    end
  end

  describe '#link_to_web_result_title' do
    result = {
      "title"=>"test title",
      "unescapedUrl"=>"https://test.gov"
    }
    subject(:link_to_web_result_title) { helper.link_to_web_result_title(result, '2') }

    it 'makes a web result title with the added data-click attribute' do
      expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;}" href="https://test.gov">test title</a>'

      expect(link_to_web_result_title).to eq expected_output
    end
  end

  describe '#link_to_sitelink' do
    subject(:link_to_sitelink) { helper.link_to_sitelink("test title", "https://test.gov", '2') }

    it 'makes a site link with the added data-click attribute' do
      expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;,&quot;module_code&quot;:&quot;DECOR&quot;}" href="https://test.gov">test title</a>'

      expect(link_to_sitelink).to eq expected_output
    end
  end

  describe '#link_to_federal_register_document_title' do
    result = Hashie::Mash.new({
      "title"=>"test title",
      "html_url"=>"https://test.gov"
    })
    subject(:link_to_federal_register_document_title) { helper.link_to_federal_register_document_title(result, '2') }

    it 'makes a federal register document title with the added data-click attribute' do
      expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;,&quot;module_code&quot;:&quot;FRDOC&quot;}" href="https://test.gov">test title</a>'

      expect(link_to_federal_register_document_title).to eq expected_output
    end
  end

  describe '#link_to_image_result_title' do
    image_result = {
      "Thumbnail" => {
        "Url" => "https://test.gov",
      },
      "title" => "test title",
      "Url" => "https://test.gov",
    }
    subject(:link_to_image_result_title) { helper.link_to_image_result_title(image_result, '2') }

    it 'adds a hidden image result title with click tracking attributes' do
      expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;}"'\
      ' tabindex="-1" href="https://test.gov">test title</a>'

      expect(link_to_image_result_title).to eq expected_output
    end
  end

  describe '#link_to_image_thumbnail' do
    image_result = {
      "Thumbnail" => {
        "Url" => "https://test.gov",
      },
      "title" => "test title",
      "Url" => "https://test.gov",
    }
    subject(:link_to_image_thumbnail) { helper.link_to_image_thumbnail(image_result, '2') }

    it 'shows an image thumbnail with click tracking attributes' do
      expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;}" '\
      'href="https://test.gov"><img alt="test title" src="https://test.gov" /></a>'

      expect(link_to_image_thumbnail).to eq expected_output
    end
  end

  describe '#link_to_news_item_title' do
    instance = Hashie::Mash.new({
      "title"=>"Marketplace",
      "link"=>"https://www.healthcare.gov/glossary/marketplace"
    })
    subject(:link_to_news_item_title) { helper.link_to_news_item_title(instance, '2') }

    it 'adds a news item title with click tracking attributes' do
      expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;,&quot;module_code&quot;:&quot;NEWS&quot;}" href="https://www.healthcare.gov/glossary/marketplace"><strong>Marketplace</strong></a>'

      expect(link_to_news_item_title).to eq expected_output
    end
  end

  describe '#link_to_news_item_thumbnail' do
    instance = Hashie::Mash.new({
      "title"=>"Marketplace",
      "link"=>"https://test.gov?v=test-video-id",
      "thumbnail_url"=>"https://test.gov",
      "youtube_thumbnail_url"=>"https://i.ytimg.com/vi/uwUt1fVLb3E/default.jpg"
    })

    subject(:link_to_news_item_thumbnail) { helper.link_to_news_item_thumbnail(module_code, instance, '2') }

    context 'NIMAG' do
      let(:module_code) { 'NIMAG' }

      it 'adds a news item thumbnail with click tracking attributes' do
        expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;,'\
                          '&quot;module_code&quot;:&quot;NIMAG&quot;}" href="https://test.gov?v=test-video-id">'\
                          '<img alt="Marketplace" src="https://test.gov" /></a>'

        expect(link_to_news_item_thumbnail).to eq expected_output
      end
    end

    context 'VIDS' do
      let(:module_code) { 'VIDS' }

      it 'adds a news item thumbnail with click tracking attributes' do
        expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;,'\
                          '&quot;module_code&quot;:&quot;VIDS&quot;}" '\
                          'href="https://test.gov?v=test-video-id">'\
                          '<img alt="Marketplace" src="https://i.ytimg.com/vi/uwUt1fVLb3E/default.jpg" />'\
                          '<span><span class="icon icon-play"></span></span></a>'

        expect(link_to_news_item_thumbnail).to eq expected_output
      end
    end
  end

  describe '#link_to_tweet_link' do
    let!(:profile) { twitter_profiles('usasearch') }
    let(:tweet) do
      Tweet.create(:tweet_text => "A <b>tweet</b> with \n http://t.co/h5vNlSdL and http://t.co/YQQSs9bb",
        :tweet_id => 123456,
        :published_at => Time.now,
        :twitter_profile_id => profile.twitter_id)
    end
    subject(:link_to_tweet_link) { helper.link_to_tweet_link(tweet, 'tweet title', tweet.url_to_tweet, 2) }

    it 'adds a tweet link with click tracking attributes' do
      expected_output = '<a data-click="{&quot;position&quot;:2,&quot;module_code&quot;:&quot;TWEET&quot;}" href="https://twitter.com/USASearch/status/123456">tweet title</a>'

      expect(link_to_tweet_link).to eq expected_output
    end
  end

  describe '#link_to_related_search' do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:search) { instance_double('search', affiliate: affiliate) }
    let(:related) { "<strong>president</strong> inauguration" }
    subject(:link_to_related_search) { helper.link_to_related_search(search, related, '2') }

    it 'adds a related search with click tracking attributes' do
      expected_output = '<a data-click="{&quot;position&quot;:&quot;2&quot;,'\
                        '&quot;module_code&quot;:&quot;SREL&quot;}" '\
                        'href="/search?affiliate=nps.gov&amp;query=president+inauguration">'\
                        '<strong>president</strong> inauguration</a>'

      expect(link_to_related_search).to eq expected_output
    end
  end
end
