require 'spec_helper'

describe SpellingSuggestion do
  describe '#cleaned' do
    context 'when suggestion is different from misspelled term' do
      let(:spelling_suggestion) { SpellingSuggestion.new("p'resident", 'president') }

      it 'should return spelling suggestion' do
        expect(spelling_suggestion.cleaned).to eq('president')
      end
    end

    context 'when suggestions for misspelled terms contain scopeid or parentheses or excluded domains' do
      let(:spelling_suggestion) { SpellingSuggestion.new('(electro coagulation) site:uspto.gov', '(electrocoagulation) (site:uspto.gov) (-site:www1.ftc.gov and -site:www2.ftc.gov and -site:www3.ftc.gov and -site:www2.ftc.gov)') }

      it 'should strip them all out' do
        expect(spelling_suggestion.cleaned).to eq('electrocoagulation')
      end
    end

    context 'when suggestions for misspelled terms contain a language specification' do
      let(:spelling_suggestion) { SpellingSuggestion.new('(enfermedades del korazón) language:es (scopeid:usagovall OR site:gov OR site:mil)', 'enfermedades del corazon language:es (scopeid:usagovall | site:gov | site:mil)') }

      it 'should strip them all out' do
        expect(spelling_suggestion.cleaned).to eq('enfermedades del corazon')
      end
    end

    context 'when original query contained misspelled word and site: param' do
      let(:spelling_suggestion) { SpellingSuggestion.new('(fedderal site:ftc.gov)', '(federal site:ftc.gov) (-site:www1.ftc.gov and -site:www2.ftc.gov and -site:www3.ftc.gov and -site:www2.ftc.gov)') }

      it 'should strip them all out' do
        expect(spelling_suggestion.cleaned).to eq('federal')
      end
    end

    context 'when the Bing spelling suggestion is identical to the original query except for Bing highlight characters' do
      let(:spelling_suggestion) { SpellingSuggestion.new('ct-w4', "(\ue000ct-w4\ue001)") }

      it 'should not have a spelling suggestion' do
        expect(spelling_suggestion.cleaned).to be_nil
      end
    end

    context 'when the Bing spelling suggestion is identical to the original query except for a hyphen' do
      let(:spelling_suggestion) { SpellingSuggestion.new('bio-tech', '(biotech)') }

      it 'should not have a spelling suggestion' do
        expect(spelling_suggestion.cleaned).to be_nil
      end
    end

    context 'when the original query was a spelling override (i.e., starting with +)' do
      let(:spelling_suggestion) { SpellingSuggestion.new('+fedderal', '(++fedderal) (site:uspto.gov) (-site:www1.ftc.gov and -site:www2.ftc.gov and -site:www3.ftc.gov and -site:www2.ftc.gov)') }

      it 'should not have a spelling suggestion' do
        expect(spelling_suggestion.cleaned).to be_nil
      end
    end

    context 'when the query and suggestion are the same except for case' do
      let(:spelling_suggestion) { SpellingSuggestion.new('Womens Health', 'womens health') }

      it 'should not have a spelling suggestion' do
        expect(spelling_suggestion.cleaned).to be_nil
      end
    end

  end
end