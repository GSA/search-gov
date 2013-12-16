require 'spec_helper'

describe FeaturedCollectionsHelper do
  describe "#featured_collection_link_with_click_tracking" do
    let(:url) { mock('url') }
    context "when the url is blank" do
      before do
        url.should_receive(:blank?).and_return(true)
      end

      specify { helper.featured_collection_link_with_click_tracking('link title', url, nil, 'query term', 1, :web, 1234).should == 'link title' }
    end

    context "when the url is not blank" do
      before do
        url.should_receive(:blank?).and_return(false)
        helper.should_receive(:link_with_click_tracking).with('link title', url, nil, 'query term', 1, 'BBG', :web, 1234).and_return('link with click tracking')
      end

      specify { helper.featured_collection_link_with_click_tracking('link title', url, nil, 'query term', 1, :web, 1234).should == 'link with click tracking' }
    end
  end

  describe "#render_featured_collection_image" do
    context "when the featured collection has an image and successfully retrieve the image" do
      context "with one column layout" do
        let(:image) { mock('image') }
        let(:featured_collection) { mock_model(FeaturedCollection, { :has_one_column_layout? => true,
                                                                     :image => image,
                                                                     :image_file_name => 'test.png',
                                                                     :image_alt_text => 'alt text',
                                                                     :image_attribution => 'attribution',
                                                                     :image_attribution_url => 'http://image.attribution.url' }) }

        before do
          image.should_receive(:url).with(:medium).and_return('http://medium.image.url')
        end

        subject { helper.render_featured_collection_image(featured_collection) }

        it { should have_selector ".image img[src='http://medium.image.url'][alt='alt text']" }
        it { should have_selector ".image span", :content => 'Image:' }
        it { should have_selector ".image a[href='http://image.attribution.url'] span.attribution", :content => 'attribution' }
      end

      context "with two column layout" do
        let(:image) { mock('image') }
        let(:featured_collection) { mock_model(FeaturedCollection, { :has_one_column_layout? => false,
                                                                     :image => image,
                                                                     :image_file_name => 'test.png',
                                                                     :image_alt_text => 'alt text',
                                                                     :image_attribution => 'attribution',
                                                                     :image_attribution_url => 'http://image.attribution.url' }) }

        before do
          image.should_receive(:url).with(:small).and_return('http://small.image.url')
        end

        subject { helper.render_featured_collection_image(featured_collection) }

        it { should have_selector ".image img[src='http://small.image.url'][alt='alt text']" }
        it { should have_selector ".image span", :content => 'Image:' }
        it { should have_selector ".image a[href='http://image.attribution.url'] span.attribution", :content => 'attribution' }
      end

      context "without image attribution URL" do
         let(:image) { mock('image') }
        let(:featured_collection) { mock_model(FeaturedCollection, { :has_one_column_layout? => true,
                                                                     :image => image,
                                                                     :image_file_name => 'test.png',
                                                                     :image_alt_text => 'alt text',
                                                                     :image_attribution => 'attribution text',
                                                                     :image_attribution_url => nil }) }

        before do
          image.should_receive(:url).with(:medium).and_return('http://medium.image.url')
        end

        subject { helper.render_featured_collection_image(featured_collection) }

        it { should have_selector ".image img[src='http://medium.image.url'][alt='alt text']" }
        it { should have_selector ".image span.attribution", :content => 'attribution text' }
        it { should_not have_selector ".image a" }
      end

      context "without image attribution" do
         let(:image) { mock('image') }
        let(:featured_collection) { mock_model(FeaturedCollection, { :has_one_column_layout? => true,
                                                                     :image => image,
                                                                     :image_file_name => 'test.png',
                                                                     :image_alt_text => 'alt text',
                                                                     :image_attribution => nil,
                                                                     :image_attribution_url => nil }) }

        before do
          image.should_receive(:url).with(:medium).and_return('http://medium.image.url')
        end

        subject { helper.render_featured_collection_image(featured_collection) }

        it { should have_selector ".image img[src='http://medium.image.url'][alt='alt text']" }
        it { should_not have_selector ".image span" }
        it { should_not have_selector ".image a" }
      end
    end

    context "when the featured collection has an image and an exception occurs when trying to retrieve the image" do
      context "with one column layout" do
        let(:image) { mock('image') }
        let(:featured_collection) { mock_model(FeaturedCollection, { :has_one_column_layout? => true,
                                                                     :image => image,
                                                                     :image_file_name => 'test.png',
                                                                     :image_alt_text => 'alt text',
                                                                     :image_attribution => 'attribution',
                                                                     :image_attribution_url => 'http://image.attribution.url' }) }

        before do
          image.should_receive(:url).with(:medium).and_raise
        end

        specify { helper.render_featured_collection_image(featured_collection).should be_blank }
      end
    end
  end

  describe '#featured_collection_image' do
    context 'when fc.image raises CloudFiles::Exception::InvalidResponse' do
      it 'returns nil' do
        fc = mock_model(FeaturedCollection, image_file_name: 'small.jpg')
        fc.should_receive(:image).and_raise CloudFiles::Exception::InvalidResponse.new
        helper.featured_collection_image(fc).should be_nil
      end
    end
  end

  describe '#featured_collection_link_titles' do
    context 'when link titles are not highlighted' do
      it 'returns an array link titles' do
        links = [mock_model(FeaturedCollectionLink, title: 'title1'),
                       mock_model(FeaturedCollectionLink, title: 'title2')]
        fc = mock_model(FeaturedCollection, featured_collection_links: links)
        hit = mock('FeaturedCollection hit', instance: fc)
        hit.should_receive(:highlights).with(:link_titles).and_return nil
        helper.featured_collection_link_titles(hit).should == %w(title1 title2)
      end
    end
  end
end
