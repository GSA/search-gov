require 'spec_helper'

describe ApplyFiltersToSaytSuggestion, "#perform(id)" do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:usagov_affiliate)
    @phrase = "ought to get deleted xxx"
    @ss = SaytSuggestion.create!(:affiliate => @affiliate, :phrase => @phrase)
  end

  it_behaves_like 'a ResqueJobStats job'

  it 'should return if it cannot find the entry' do
    ApplyFiltersToSaytSuggestion.perform(-1).should be_nil
  end

  context 'when SaytFilters disallow the phrase' do
    it 'should destroy the SaytSuggestion' do
      SaytFilter.should_receive(:filter).with([@phrase]).and_return []
      ApplyFiltersToSaytSuggestion.perform(@ss.id)
      SaytSuggestion.find_by_phrase(@phrase).should be_nil
    end
  end

  context 'when SaytSuggestion matches whitelist filter' do
    it 'should set the is_whitelisted flag' do
      SaytFilter.stub(:filter).with([@phrase]).and_return [@phrase]
      SaytFilter.stub(:filters_match?).with(SaytFilter.accept, @phrase).and_return true
      ApplyFiltersToSaytSuggestion.perform(@ss.id)
      SaytSuggestion.find_by_phrase(@phrase).is_whitelisted?.should be true
    end
  end

end
