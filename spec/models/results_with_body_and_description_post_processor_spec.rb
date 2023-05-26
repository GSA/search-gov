# frozen_string_literal: true

require 'spec_helper'

describe ResultsWithBodyAndDescriptionPostProcessor do
  describe '#normalized_results' do
    subject(:normalized_results) { described_class.new(results).normalized_results(5) }

    let(:results) do
      results = []
      5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", description: "content #{index}", url: "http://foo.gov/#{index}") }
      results
    end

    it_behaves_like 'a search with normalized results' do
      let(:normalized_results) { described_class.new(results).normalized_results(5) }
    end

    it 'does not use unbounded pagination' do
      expect(normalized_results[:unboundedResults]).to be false
    end
  end
end
