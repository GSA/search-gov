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

    context 'when there are video results' do
      subject(:normalized_results) { described_class.new(results, _val: nil, youtube: true).normalized_results(5) }

      let(:results) do
        results = []
        5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", description: "content #{index}", url: "http://foo.gov/#{index}", published_at: DateTime.parse('2011-09-26'), youtube_thumbnail_url: "http://youtube.com/#{index}", duration: '1:23') }
        results
      end

      it 'returns results with video data' do
        normalized_results[:results].each_with_index do |result, index|
          expect(result[:title]).to eq("title #{index}")
          expect(result[:description]).to eq("content #{index}")
          expect(result[:url]).to eq("http://foo.gov/#{index}")
          expect(result[:publishedAt]).to eq('about 12 years ago')
          expect(result[:youtube]).to be true
          expect(result[:youtubePublishedAt]).to eq(DateTime.parse('2011-09-26'))
          expect(result[:youtubeThumbnailUrl]).to eq("http://youtube.com/#{index}")
          expect(result[:youtubeDuration]).to eq('1:23')
        end
      end
    end
  end
end
