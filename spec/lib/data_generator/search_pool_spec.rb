require 'spec_helper'

module DataGenerator
  describe SearchPool do
    subject { described_class.new(variation_count, results_per_query, clicks_per_search, fake) }
    let(:variation_count) { 1 }
    let(:results_per_query) { 1 }
    let(:clicks_per_search) { 2 }
    let(:timestamp) { Time.new(1997, 8, 29, 6, 14, 0) }
    let(:modules) { ['NEWS', 'IMAG', 'JOBS'] }
    let(:fake) do
      double('Fake', {
        timestamp: timestamp,
        is_human?: true,
        modules: ['NEWS', 'IMAG', 'JOBS'],
        search_query: 'the ants in france',
        url: 'http://ants.com',
      })
    end

    describe '#search_session' do
      it 'should contain a search and clicks with random data created by the fake' do
        clicks = [Click.new('http://ants.com', 1)]
        expect(subject.search_session).to eq(Search.new(timestamp, true, modules, 'the ants in france', clicks))
      end
    end
  end
end
