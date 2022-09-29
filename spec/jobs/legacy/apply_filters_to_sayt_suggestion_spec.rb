require 'spec_helper'

describe ApplyFiltersToSaytSuggestion, '#perform(id)' do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:usagov_affiliate)
    @phrase = 'ought to get deleted xxx'
    @ss = SaytSuggestion.create!(affiliate: @affiliate, phrase: @phrase)
  end

  it_behaves_like 'a ResqueJobStats job'

  it 'should return if it cannot find the entry' do
    expect(described_class.perform(-1)).to be_nil
  end

  context 'when SaytFilters disallow the phrase' do
    it 'should destroy the SaytSuggestion' do
      expect(SaytFilter).to receive(:filter).with([@phrase]).and_return []
      described_class.perform(@ss.id)
      expect(SaytSuggestion.find_by_phrase(@phrase)).to be_nil
    end
  end

  context 'when SaytSuggestion matches whitelist filter' do
    it 'should set the is_whitelisted flag' do
      allow(SaytFilter).to receive(:filter).with([@phrase]).and_return [@phrase]
      allow(SaytFilter).to receive(:filters_match?).with(SaytFilter.accept, @phrase).and_return true
      described_class.perform(@ss.id)
      expect(SaytSuggestion.find_by_phrase(@phrase).is_whitelisted?).to be true
    end
  end

end
