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

    it_behaves_like 'a search with normalized results' do
      let(:normalized_results) { described_class.new(results).normalized_results }
    end
  end
end
