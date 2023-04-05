require 'spec_helper'

describe ResultsWithBodyAndDescriptionPostProcessor do
  describe '#normalized_results' do
    let(:normalized_result_keys) { [:description, :url, :title] }
    let(:results) do
      results = []
      5.times { |x| results << Hashie::Mash::Rash.new(title: 'title', description: 'content', url: "http://foo.gov/#{x}") }
      results
    end
    let(:excluded_urls) { [] }
    let(:normalized_results) { described_class.new(results).normalized_results }

    it 'returns normalized results' do
      expect(normalized_results.length).to eq(5)

      normalized_results.each_with_index do |result, index|
        expect(result.keys).to contain_exactly(*normalized_result_keys)
        expect(result[:title]).to eq('title')
        expect(result[:description]).to eq('content')
        expect(result[:url]).to eq("http://foo.gov/#{index}")
      end
    end
  end
end
