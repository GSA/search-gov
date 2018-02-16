require 'spec_helper'

describe NavigationsHelper do
  shared_examples_for 'doing search on everything' do
    it 'should render default search label' do
      html = helper.render_navigations(affiliate, search, search_params)
      expect(html).to have_selector('.navigations', text: 'Everything')
    end

    it 'should not render a link to default search label' do
      html = helper.render_navigations(affiliate, search, search_params)
      expect(html).not_to have_selector('.navigations a', text: 'Everything')
    end
  end

  shared_examples_for 'doing non web search' do
    it 'should render a link to default search label' do
      html = helper.render_navigations(affiliate, search, search_params)
      expect(html).to have_selector('.navigations a', text: 'Everything')
    end
  end

  shared_examples_for 'doing non image search' do
    it 'should render a link to image search label' do
      html = helper.render_navigations(affiliate, search, search_params)
      expect(html).to have_selector('.navigations a', text: 'Images')
    end
  end

  shared_examples_for 'doing non odie search' do
    it 'should render a link to document collection' do
      html = helper.render_navigations(affiliate, search, search_params)
      expect(html).to have_selector('.navigations a', text: 'Blog')
    end
  end

  shared_examples_for 'doing non news channel specific search' do
    it 'should render a link to rss feed' do
      html = helper.render_navigations(affiliate, search, search_params)
      expect(html).to have_selector('.navigations a', text: 'News')
    end
  end

  describe '#filter_navigations' do
    let(:image_search_label) { mock_model(ImageSearchLabel, name: 'Images') }

    let(:image_nav) do
      mock_model(Navigation,
                 :navigable => image_search_label,
                 :navigable_type => image_search_label.class.name)
    end

    let(:media_nav) do
      mock_model(Navigation,
                 navigable: mock_model(RssFeed,
                                       is_managed: false,
                                       name: 'Photos',
                                       show_only_media_content?: true))
    end

    let(:press_nav) do
      mock_model(Navigation,
                 navigable: mock_model(RssFeed,
                                       is_managed: false,
                                       name: 'Press',
                                       show_only_media_content?: false))
    end

    let(:affiliate) { mock_model(Affiliate,
                                 default_search_label: 'Everything',
                                 name: 'myaff') }

    context 'when is_bing_image_search_enabled=true' do
      before do
        expect(affiliate).to receive(:has_social_image_feeds?).and_return(true)
        expect(affiliate).to receive(:navigations).and_return([image_nav, media_nav, press_nav])
      end

      it 'returns only the image nav' do
        expect(helper.filter_navigations(affiliate, affiliate.navigations)).to eq([image_nav, press_nav])
      end
    end

    context 'when is_bing_image_search_enabled=false' do
      before do
        expect(affiliate).to receive(:has_social_image_feeds?).and_return(false)
        expect(affiliate).to receive(:is_bing_image_search_enabled?).and_return(false)
        expect(affiliate).to receive(:navigations).and_return([image_nav, media_nav, press_nav])
      end

      it 'returns only the press nav' do
        expect(helper.filter_navigations(affiliate, affiliate.navigations)).to eq([press_nav])
      end
    end
  end

  describe '#render_navigations' do
    let(:affiliate) { mock_model(Affiliate, :name => 'myaff', :default_search_label => 'Everything') }

    let(:search_params) { { :query => 'gov', :affiliate => 'myaff' } }

    let(:image_search_label) { mock_model(ImageSearchLabel, :name => 'Images') }
    let(:image_nav) do
      mock_model(Navigation,
                 :navigable => image_search_label,
                 :navigable_type => image_search_label.class.name)
    end

    let(:rss_feed) { mock_model(RssFeed, :name => 'News') }
    let(:rss_feed_nav) do
      mock_model(Navigation,
                 :navigable => rss_feed,
                 :navigable_type => rss_feed.class.name)
    end

    let(:another_rss_feed) { mock_model(RssFeed, :name => 'Press Releases') }
    let(:another_rss_feed_nav) do
      mock_model(Navigation,
                 :navigable => another_rss_feed,
                 :navigable_type => another_rss_feed.class.name)
    end

    let(:document_collection) { mock_model(DocumentCollection, :name => 'Blog') }

    let(:document_collection_nav) do
      mock_model(Navigation,
                 :navigable => document_collection,
                 :navigable_type => document_collection.class.name)
    end

    let(:non_navigable_document_collection) { mock_model(DocumentCollection, name: 'News') }

    let(:search_params) { { :query => 'gov', :affiliate => affiliate.name } }

    context 'when there is no active navigation' do
      before { allow(affiliate).to receive_message_chain(:navigations, :active).and_return([]) }

      specify { expect(helper.render_navigations(affiliate, double(WebSearch), search_params)).to be_blank }
    end

    context 'when there are active navigations' do
      before do
        allow(affiliate).to receive_message_chain(:navigations, :active).
            and_return([image_nav, rss_feed_nav, document_collection_nav])
      end

      context 'when doing web search' do
        let(:search) { double(WebSearch) }

        before do
          expect(search).to receive(:instance_of?).at_least(:once) { |arg| arg == WebSearch }
        end

        it_behaves_like 'doing search on everything'
        it_behaves_like 'doing non image search'
        it_behaves_like 'doing non odie search'
        it_behaves_like 'doing non news channel specific search'
      end

      context 'when doing image search' do
        let(:search) { double(LegacyImageSearch) }

        before do
          expect(search).to receive(:instance_of?).at_least(:once) { |arg| arg == LegacyImageSearch }
        end

        it 'should render image search label' do
          html = helper.render_navigations(affiliate, search, search_params)
          expect(html).to have_selector('.navigations', text: 'Images')
        end

        it 'should not render a link to image search label' do
          html = helper.render_navigations(affiliate, search, search_params)
          expect(html).not_to have_selector('.navigations a', text: 'Images')
        end

        it_behaves_like 'doing non web search'
        it_behaves_like 'doing non odie search'
        it_behaves_like 'doing non news channel specific search'
      end

      context 'when doing search on a specific document collection' do
        let(:search) { double(SiteSearch) }

        before do
          expect(search).to receive(:instance_of?).at_least(:once) { |arg| arg == SiteSearch }
          expect(search).to receive(:is_a?).at_least(:once) { |arg| arg == SiteSearch }
          expect(search).to receive(:document_collection).at_least(:once).and_return(document_collection)
          allow(document_collection).to receive_message_chain(:navigation, :is_active?).and_return(true)
        end

        it 'should render document collection name' do
          html = helper.render_navigations(affiliate, search, search_params)
          expect(html).to have_selector('.navigations', text: 'Blog')
        end

        it 'should not render a link to document collection' do
          html = helper.render_navigations(affiliate, search, search_params)
          expect(html).not_to have_selector('.navigations a', text: 'Blog')
        end

        it_behaves_like 'doing non web search'
        it_behaves_like 'doing non image search'
        it_behaves_like 'doing non news channel specific search'
      end

      context 'when searching on non navigable document collection' do
        let(:search) { double(SiteSearch) }

        before do
          expect(search).to receive(:is_a?).at_least(:once) { |arg| arg == SiteSearch }
          expect(search).to receive(:document_collection).at_least(:once).and_return(non_navigable_document_collection)
          allow(non_navigable_document_collection).to receive_message_chain(:navigation, :is_active?).and_return(false)
        end

        it 'should render document collection name' do
          html = helper.render_navigations(affiliate, search, search_params)
          expect(html).to have_selector('.navigations', text: 'News')
        end

        it 'should not render a link to document collection' do
          html = helper.render_navigations(affiliate, search, search_params)
          expect(html).not_to have_selector('.navigations a', text: 'News')
        end
      end

      context 'when doing search on a specific news channel' do
        let(:search) { double(NewsSearch, since:nil, until: nil) }

        before do
          expect(search).to receive(:instance_of?).at_least(:once) { |arg| arg == NewsSearch }
          expect(search).to receive(:is_a?).at_least(:once) { |arg| arg == NewsSearch }
          expect(search).to receive(:rss_feed).and_return(rss_feed)
        end

        it 'should render rss feed name' do
          html = helper.render_navigations(affiliate, search, search_params)
          expect(html).to have_selector('.navigations', text: 'News')
        end

        it 'should not render a link to rss feed' do
          html = helper.render_navigations(affiliate, search, search_params)
          expect(html).not_to have_selector('.navigations a', text: 'News')
        end

        it_behaves_like 'doing non web search'
        it_behaves_like 'doing non image search'
        it_behaves_like 'doing non odie search'
      end
    end

    context 'when there are more than 1 active rss feed navigations' do
      let(:search) { double(NewsSearch, since:nil, until: nil) }

      before do
        allow(affiliate).to receive_message_chain(:navigations, :active).and_return(
            [image_nav, rss_feed_nav, document_collection_nav, another_rss_feed_nav])
        expect(search).to receive(:instance_of?).at_least(:once) { |arg| arg == NewsSearch }
        expect(search).to receive(:is_a?).at_least(:once) { |arg| arg == NewsSearch }
      end

      context 'when not doing search on a specific news channel' do
        before { expect(search).to receive(:rss_feed).and_return(nil) }

        it_behaves_like 'doing search on everything'
        it_behaves_like 'doing non image search'
        it_behaves_like 'doing non odie search'
        it_behaves_like 'doing non news channel specific search'
      end
    end
  end
end
