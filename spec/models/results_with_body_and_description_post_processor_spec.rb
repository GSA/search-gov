# frozen_string_literal: true

require 'spec_helper'

describe ResultsWithBodyAndDescriptionPostProcessor do
  describe '#normalized_results' do
    subject(:normalized_results) { described_class.new(results, _val: nil).normalized_results(5) }

    let(:results) do
      results = []
      5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", description: "content #{index}", url: "http://foo.gov/#{index}") }
      results
    end

    it_behaves_like 'a search with normalized results' do
      let(:normalized_results) { described_class.new(results, _val: nil).normalized_results(5) }
    end

    it 'does not use unbounded pagination' do
      expect(normalized_results[:unboundedResults]).to be false
    end

    context 'when a results have url that has file extension' do
      subject(:normalized_results) { described_class.new(results, _val: nil).normalized_results(1) }

      let(:results) do
        [] << Hashie::Mash::Rash.new(title: 'file type title', description: 'file type content', url: 'http://foo.gov.pdf', published_at: DateTime.parse('2011-09-26'))
      end

      it 'returns results including fileType data' do
        expect(normalized_results[:results].first).to include(:fileType)
        expect(normalized_results[:results].first[:fileType]).to eq('PDF')
      end
    end

    context 'when a results does not have url that has file extension' do
      subject(:normalized_results) { described_class.new(results, _val: nil).normalized_results(1) }

      let(:results) do
        [] << Hashie::Mash::Rash.new(title: 'file type title', description: 'file type content', url: 'http://foo.gov', published_at: DateTime.parse('2011-09-26'))
      end

      it 'returns results without fileType data' do
        expect(normalized_results[:results].first).not_to include(:fileType)
      end
    end

    context 'when there are indexed document results' do
      subject(:normalized_results) { described_class.new(results, _val: nil).normalized_results(5) }

      let(:results) do
        5.times.map { |index| IndexedDocument.new(title: "title #{index}", description: "content #{index}", url: "http://foo.gov/#{index}") }
      end

      it 'returns the news results the module code' do
        normalized_results[:results].each do |result|
          expect(result[:blendedModule]).to eq('AIDOC')
        end
      end
    end
  end
end
