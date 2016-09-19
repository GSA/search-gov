require 'spec_helper'

describe FeaturedCollectionsHelper do

  describe "#render_featured_collection_image" do
    context "when the featured collection has an image and successfully retrieve the image" do
      let(:image) { mock('image') }
      let(:featured_collection) { mock_model(FeaturedCollection,
                                             { image: image,
                                               image_file_name: 'test.png',
                                               image_alt_text: 'alt text' }) }

      before do
        image.should_receive(:url).with(:small).and_return('http://small.image.url')
      end

      subject { helper.render_featured_collection_image(featured_collection) }

      it { should have_selector ".image img[src='http://small.image.url'][alt='alt text']" }
      it { should_not have_selector ".image a" }
    end

    context "when the featured collection has an image and an exception occurs when trying to retrieve the image" do
      let(:image) { mock('image') }
      let(:featured_collection) { mock_model(FeaturedCollection,
                                             { image: image,
                                               image_file_name: 'test.png',
                                               image_alt_text: 'alt text' }) }

      before do
        image.should_receive(:url).with(:small).and_raise
      end

      it 'returns blank' do
        helper.render_featured_collection_image(featured_collection).should be_blank
      end
    end
  end

  describe '#featured_collection_image' do
    context 'when fc.image is present' do
      let(:fc) { FeaturedCollection.new(image_file_name: 'corgi.jpg') }
      it 'returns the content tag' do
        expect(helper.featured_collection_image(fc)).
          to eq "<div class=\"image\"><img src=\"#{fc.image.url(:medium)}\" /></div>"
      end
    end

    context 'when fc.image is missing' do
      it 'returns nil' do
        fc = mock_model(FeaturedCollection, image_file_name: 'small.jpg')
        fc.stub_chain(:image_file_name, :present?).and_return(false)
        helper.featured_collection_image(fc).should be_nil
      end
    end

    context 'when an error occurs' do
      it 'returns nil' do
        fc = mock_model(FeaturedCollection, image_file_name: 'small.jpg')
        fc.should_receive(:image).and_raise StandardError
        helper.featured_collection_image(fc).should be_nil
      end
    end
  end
end
