require 'spec_helper'

describe FeaturedCollectionsHelper do

  describe "#render_featured_collection_image" do
    context "when the featured collection has an image and successfully retrieve the image" do
      context "with image attribution URL" do
        let(:image) { mock('image') }
        let(:featured_collection) { mock_model(FeaturedCollection, { :image => image,
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
        let(:featured_collection) { mock_model(FeaturedCollection, { :image => image,
                                                                     :image_file_name => 'test.png',
                                                                     :image_alt_text => 'alt text',
                                                                     :image_attribution => 'attribution text',
                                                                     :image_attribution_url => nil }) }

        before do
          image.should_receive(:url).with(:small).and_return('http://small.image.url')
        end

        subject { helper.render_featured_collection_image(featured_collection) }

        it { should have_selector ".image img[src='http://small.image.url'][alt='alt text']" }
        it { should have_selector ".image span.attribution", :content => 'attribution text' }
        it { should_not have_selector ".image a" }
      end

      context "without image attribution" do
        let(:image) { mock('image') }
        let(:featured_collection) { mock_model(FeaturedCollection, { :image => image,
                                                                     :image_file_name => 'test.png',
                                                                     :image_alt_text => 'alt text',
                                                                     :image_attribution => nil,
                                                                     :image_attribution_url => nil }) }

        before do
          image.should_receive(:url).with(:small).and_return('http://small.image.url')
        end

        subject { helper.render_featured_collection_image(featured_collection) }

        it { should have_selector ".image img[src='http://small.image.url'][alt='alt text']" }
        it { should_not have_selector ".image span" }
        it { should_not have_selector ".image a" }
      end
    end

    context "when the featured collection has an image and an exception occurs when trying to retrieve the image" do
      let(:image) { mock('image') }
      let(:featured_collection) { mock_model(FeaturedCollection, { :image => image,
                                                                   :image_file_name => 'test.png',
                                                                   :image_alt_text => 'alt text',
                                                                   :image_attribution => 'attribution',
                                                                   :image_attribution_url => 'http://image.attribution.url' }) }

      before do
        image.should_receive(:url).with(:small).and_raise
      end

      it 'returns blank' do
        helper.render_featured_collection_image(featured_collection).should be_blank
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

end
