require 'spec_helper'

describe WebResultsPostProcessor do
  fixtures :affiliates

  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:post_processor) { described_class.new('foo', affiliate, results) }

  describe '#normalized_results' do
    subject(:normalized_results) { post_processor.normalized_results(5) }

    let(:results) do
      results = []
      5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", content: "content #{index}", unescaped_url: "http://foo.gov/#{index}") }
      results
    end

    describe 'with an affiliate using bing' do
      it 'uses unbounded pagination' do
        expect(normalized_results[:unboundedResults]).to be true
      end
    end

    describe 'with an affiliate using searchgov' do
      let(:affiliate) { affiliates(:searchgov_affiliate) }

      it_behaves_like 'a search with normalized results' do
        let(:normalized_results) { post_processor.normalized_results(5) }
      end
    end
  end

  context 'when a results have url that has file extension' do
    subject(:normalized_results) { described_class.new('foo', affiliate, results).normalized_results(1) }

    let(:results) do
      [] << Hashie::Mash::Rash.new(title: 'file type title', content: 'file type content', unescaped_url: 'http://foo.gov.pdf')
    end

    it 'returns results including fileType data' do
      expect(normalized_results[:results].first).to include(:fileType)
      expect(normalized_results[:results].first[:fileType]).to eq('PDF')
    end
  end

  context 'when a results does not have url that has file extension' do
    subject(:normalized_results) { described_class.new('foo', affiliate, results).normalized_results(1) }

    let(:results) do
      [] << Hashie::Mash::Rash.new(title: 'file type title', content: 'file type content', unescaped_url: 'http://foo.gov')
    end

    it 'returns results without fileType data' do
      expect(normalized_results[:results].first).not_to include(:fileType)
    end
  end

end
