require 'spec_helper'

describe String do

  describe '#sentence_case' do
    it 'should properly capitalize words in a sentence' do
      expect("Loren's visit to the CIA with O'Toole and al-Gaddafi wasn't fun, so I doubt he'll return.".sentence_case).to eq("Loren's Visit to the CIA with O'Toole and al-Gaddafi Wasn't Fun, so I Doubt He'll Return.")
      expect('Muammar al-Gaddafi'.sentence_case).to eq('Muammar al-Gaddafi')
    end
  end

  describe '#extract_array' do
    it 'splits on commas, strips whitespace, and downcases' do
      expect('This, That, OTHER'.extract_array).to eq(%w[this that other])
    end

    it 'handles a single value with no comma' do
      expect('single value'.extract_array).to eq(['single value'])
    end

    it 'handles extra whitespace around values' do
      expect('  foo ,  bar  , baz '.extract_array).to eq(%w[foo bar baz])
    end

    it 'returns an array with one empty string for an empty string' do
      expect(''.extract_array).to eq([''])
    end

    it 'handles trailing commas' do
      expect('one, two,'.extract_array).to eq(['one', 'two', ''])
    end
  end
end
