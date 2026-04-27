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
    before do
      expect(affiliate).to receive(:navigations).and_return([image_nav, collection_nav])
    end

    let(:image_search_label) { mock_model(ImageSearchLabel, name: 'Images') }

    let(:image_nav) do
      mock_model(Navigation,
                 navigable: image_search_label,
                 navigable_type: image_search_label.class.name)
    end

    let(:collection_nav) do
      mock_model(Navigation,
                 navigable: mock_model(DocumentCollection,
                                       name: 'Blog'))
    end

    let(:affiliate) { mock_model(Affiliate,
                                 default_search_label: 'Everything',
                                 name: 'myaff') }

    it 'returns only DocumentCollection navigations' do
      expect(helper.filter_navigations(affiliate.navigations)).to eq([collection_nav])
    end
  end
end
