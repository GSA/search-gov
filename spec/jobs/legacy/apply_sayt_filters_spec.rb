require 'spec_helper'

describe ApplySaytFilters, '#perform' do
  fixtures :sayt_suggestions

  it 'should enqueue ApplyFiltersToSaytSuggestion for each SaytSuggestion' do
    SaytSuggestion.all.each { |ss| expect(Resque).to receive(:enqueue_with_priority).with(:high, ApplyFiltersToSaytSuggestion, ss.id) }
    described_class.perform
  end
end
