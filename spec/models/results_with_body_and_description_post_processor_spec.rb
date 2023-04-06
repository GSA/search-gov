# frozen_string_literal: true

require 'spec_helper'

describe ResultsWithBodyAndDescriptionPostProcessor do
  describe '#normalized_results' do
    let(:results) do
      results = []
      5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", description: "content #{index}", url: "http://foo.gov/#{index}") }
      results
    end
    let(:excluded_urls) { [] }

    it_behaves_like 'a search with normalized results' do
      let(:normalized_results) { described_class.new(results).normalized_results }
    end
  end
end
