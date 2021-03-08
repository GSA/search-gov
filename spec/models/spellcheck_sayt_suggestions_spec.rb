require 'spec_helper'

describe SpellcheckSaytSuggestions, '#perform(wrong,rite)' do
  fixtures :affiliates

  before do
    SaytSuggestion.create!(:phrase => 'haus', :affiliate => affiliates(:basic_affiliate))
    SaytSuggestion.create!(:phrase => 'exhaust', :affiliate => affiliates(:basic_affiliate))
  end

  it_behaves_like 'a ResqueJobStats job'

  it 'should apply the correction to existing SaytSuggestions containing the misspelled word' do
    wrong = 'haus'
    rite = 'house'
    Misspelling.create!(:wrong=> wrong, :rite=>rite)
    SpellcheckSaytSuggestions.perform(wrong, rite)
    expect(affiliates(:basic_affiliate).sayt_suggestions.find_by_phrase('haus')).to be_nil
    expect(affiliates(:basic_affiliate).sayt_suggestions.find_by_phrase('exhaust')).not_to be_nil
    expect(affiliates(:basic_affiliate).sayt_suggestions.find_by_phrase('house')).not_to be_nil
  end
end
