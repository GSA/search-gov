require 'spec_helper'

describe ImageResultsPostProcessor do
  describe '#normalized_results' do
    subject(:normalized_results) { described_class.new(total_results, results, affiliate).normalized_results }

    let(:affiliate) { affiliates(:basic_affiliate) }

    context 'when results have all attributes' do
      let(:total_results) { 5 }
      let(:results) do
        results = []
        thumbnail = Hashie::Mash::Rash.new(url: 'http://bar.gov/image.png')
        5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", url: "http://foo.gov/#{index}", thumbnail: thumbnail) }
        results
      end

      it 'has a alt text, link URL, thumbnail URL, and image' do
        normalized_results[:results].each_with_index do |result, index|
          expect(result[:altText]).to eq("title #{index}")
          expect(result[:url]).to eq("http://foo.gov/#{index}")
          expect(result[:thumbnailUrl]).to eq('http://bar.gov/image.png')
          expect(result[:image]).to eq(affiliate.display_image_on_search_results)
        end
      end

      it 'does not use unbounded pagination' do
        expect(normalized_results[:unboundedResults]).to be false
      end

      it 'returns the correct number of pages' do
        expect(normalized_results[:totalPages]).to eq(1)
      end
    end

    context 'when there are no results' do
      let(:total_results) { nil }
      let(:results) { nil }

      it 'does not have alt text, link URL, and thumbnail URL' do
        expect(normalized_results[:results]).to be_nil
      end

      it 'does not use unbounded pagination' do
        expect(normalized_results[:unboundedResults]).to be false
      end

      it 'returns the correct number of pages' do
        expect(normalized_results[:totalPages]).to eq(0)
      end
    end
  end
end
