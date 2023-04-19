# frozen_string_literal: true

require 'spec_helper'

describe ResultsWithBodyAndDescriptionPostProcessor do
  describe '#normalized_results' do
    subject(:normalized_results) { described_class.new(results).normalized_results }

    let(:test_date) { DateTime.new(2001, 2, 3, 4, 5, 6) }

    context 'when results have all attributes' do
      let(:results) do
        results = []
        5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", description: "content #{index}", url: "http://foo.gov/#{index}", updated_at: test_date, published_at: test_date) }
        results
      end

      it_behaves_like 'a search with normalized results' do
        let(:normalized_results) { described_class.new(results).normalized_results }
      end

      it 'has a published date and updated date but no thumbnail URL' do
        normalized_results.each do |result|
          expect(result[:updatedDate]).to eq('February 3rd, 2001')
          expect(result[:publishedDate]).to eq('February 3rd, 2001')
          expect(result[:thumbnailUrl]).to be_nil
        end
      end
    end

    context 'when results do not have all attributes' do
      let(:results) do
        results = []
        5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", description: "content #{index}", url: "http://foo.gov/#{index}") }
        results
      end

      it_behaves_like 'a search with normalized results' do
        let(:normalized_results) { described_class.new(results).normalized_results }
      end

      it 'has no published date, updated date, or thumbnaul URL' do
        normalized_results.each do |result|
          expect(result[:updatedDate]).to be_nil
          expect(result[:publishedDate]).to be_nil
          expect(result[:thumbnailUrl]).to be_nil
        end
      end
    end
  end
end
