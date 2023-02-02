require 'spec_helper'

describe FeaturedCollectionsHelper do
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
        allow(fc).to receive_message_chain(:image_file_name, :present?).and_return(false)
        expect(helper.featured_collection_image(fc)).to be_nil
      end
    end

    context 'when an error occurs' do
      it 'returns nil' do
        fc = mock_model(FeaturedCollection, image_file_name: 'small.jpg')
        expect(fc).to receive(:image).and_raise StandardError
        expect(helper.featured_collection_image(fc)).to be_nil
      end
    end
  end
end
