require 'spec_helper'

describe SitelinkGeneratorUtils do
  describe '.matching_generator_names' do
    it 'returns class name when the input url matches the url_prefix' do
      urls = %w(sec.gov http://www.sec.gov http://www.sec.gov/archives/edgar)
      urls.each do |input_url|
        expect(described_class.matching_generator_names([input_url])).to eq(['SitelinkGenerator::SecEdgar'])
      end
    end

    it 'returns empty array when the input url does not match the url_prefix' do
      urls = %w(test.sec.gov http://www.sec.gov/archives/notedgar)
      urls.each do |input_url|
        expect(described_class.matching_generator_names([input_url])).to be_empty
      end
    end
  end

  describe '.classes_by_names' do
    it 'returns valid classes' do
      class_names = %w(SitelinkGenerator::SecEdgar BogusKlass)
      expect(described_class.classes_by_names(class_names)).to eq([SitelinkGenerator::SecEdgar])
    end
  end
end
