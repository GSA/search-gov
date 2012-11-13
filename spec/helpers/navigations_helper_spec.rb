require 'spec_helper'

describe NavigationsHelper do
  shared_examples_for 'doing search on everything' do
    it 'should render default search label' do
      html = helper.render_navigations(affiliate, search, search_params)
      html.should have_selector('.navigations', :content => 'Everything')
    end

    it 'should not render a link to default search label' do
      html = helper.render_navigations(affiliate, search, search_params)
      html.should_not have_selector('.navigations a', :content => 'Everything')
    end
  end

  shared_examples_for 'doing non web search' do
    it 'should render a link to default search label' do
      html = helper.render_navigations(affiliate, search, search_params)
      html.should have_selector('.navigations a', :content => 'Everything')
    end
  end

  shared_examples_for 'doing non image search' do
    it 'should render a link to image search label' do
      html = helper.render_navigations(affiliate, search, search_params)
      html.should have_selector('.navigations a', :content => 'Images')
    end
  end

  shared_examples_for 'doing non odie search' do
    it 'should render a link to document collection' do
      html = helper.render_navigations(affiliate, search, search_params)
      html.should have_selector('.navigations a', :content => 'Blog')
    end
  end

  shared_examples_for 'doing non news channel specific search' do
    it 'should render a link to rss feed' do
      html = helper.render_navigations(affiliate, search, search_params)
      html.should have_selector('.navigations a', :content => 'News')
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

    let(:search_params) { { :query => 'gov', :affiliate => affiliate.name } }

    context 'when there is no active navigation' do
      before { affiliate.stub_chain(:navigations, :active).and_return([]) }

      specify { helper.render_navigations(affiliate, mock(WebSearch), search_params).should be_blank }
    end

    context 'when there are active navigations' do
      before do
        affiliate.stub_chain(:navigations, :active).
            and_return([image_nav, rss_feed_nav, document_collection_nav])
      end

      context 'when doing web search' do
        let(:search) { mock(WebSearch) }

        before do
          search.should_receive(:instance_of?).at_least(:once) { |arg| arg == WebSearch }
        end

        it_behaves_like 'doing search on everything'
        it_behaves_like 'doing non image search'
        it_behaves_like 'doing non odie search'
        it_behaves_like 'doing non news channel specific search'
      end

      context 'when doing image search' do
        let(:search) { mock(ImageSearch) }

        before do
          search.should_receive(:instance_of?).at_least(:once) { |arg| arg == ImageSearch }
        end

        it 'should render image search label' do
          html = helper.render_navigations(affiliate, search, search_params)
          html.should have_selector('.navigations', :content => 'Images')
        end

        it 'should not render a link to image search label' do
          html = helper.render_navigations(affiliate, search, search_params)
          html.should_not have_selector('.navigations a', :content => 'Images')
        end

        it_behaves_like 'doing non web search'
        it_behaves_like 'doing non odie search'
        it_behaves_like 'doing non news channel specific search'
      end

      context 'when doing search on a specific document collection' do
        let(:search) { mock(SiteSearch) }

        before do
          search.should_receive(:instance_of?).at_least(:once) { |arg| arg == SiteSearch }
          search.should_receive(:is_a?).at_least(:once) { |arg| arg == SiteSearch }
          search.should_receive(:document_collection).and_return(document_collection)
        end

        it 'should render document collection name' do
          html = helper.render_navigations(affiliate, search, search_params)
          html.should have_selector('.navigations', :content => 'Blog')
        end

        it 'should not render a link to document collection' do
          html = helper.render_navigations(affiliate, search, search_params)
          html.should_not have_selector('.navigations a', :content => 'Blog')
        end

        it_behaves_like 'doing non web search'
        it_behaves_like 'doing non image search'
        it_behaves_like 'doing non news channel specific search'
      end

      context 'when doing search on a specific news channel' do
        let(:search) { mock(NewsSearch, since:nil, until: nil) }

        before do
          search.should_receive(:instance_of?).at_least(:once) { |arg| arg == NewsSearch }
          search.should_receive(:is_a?).at_least(:once) { |arg| arg == NewsSearch }
          search.should_receive(:rss_feed).and_return(rss_feed)
        end

        it 'should render rss feed name' do
          html = helper.render_navigations(affiliate, search, search_params)
          html.should have_selector('.navigations', :content => 'News')
        end

        it 'should not render a link to rss feed' do
          html = helper.render_navigations(affiliate, search, search_params)
          html.should_not have_selector('.navigations a', :content => 'News')
        end

        it_behaves_like 'doing non web search'
        it_behaves_like 'doing non image search'
        it_behaves_like 'doing non odie search'
      end
    end

    context 'when there are more than 1 active rss feed navigations' do
      let(:search) { mock(NewsSearch, since:nil, until: nil) }

      before do
        affiliate.stub_chain(:navigations, :active).and_return(
            [image_nav, rss_feed_nav, document_collection_nav, another_rss_feed_nav])
        search.should_receive(:instance_of?).at_least(:once) { |arg| arg == NewsSearch }
        search.should_receive(:is_a?).at_least(:once) { |arg| arg == NewsSearch }
      end

      context 'when not doing search on a specific news channel' do
        before { search.should_receive(:rss_feed).and_return(nil) }

        it_behaves_like 'doing search on everything'
        it_behaves_like 'doing non image search'
        it_behaves_like 'doing non odie search'
        it_behaves_like 'doing non news channel specific search'
      end
    end
  end
end
