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
                 navigable: image_search_label,
                 navigable_type: image_search_label.class.name)
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
end
