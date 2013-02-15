require 'spec_helper'

describe ApplySaytFilters, "#perform" do
  it 'should enqueue ApplyFiltersToSaytSuggestion for each SaytSuggestion' do
    SaytSuggestion.all.each { |ss| Resque.should_receive(:enqueue_with_priority).with(:high, ApplyFiltersToSaytSuggestion, ss.id) }
    ApplySaytFilters.perform
  end
end