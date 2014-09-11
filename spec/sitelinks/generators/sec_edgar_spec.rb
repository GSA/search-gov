require 'spec_helper'

describe Sitelinks::Generators::SecEdgar do
  describe '.matching_generators' do
    it 'returns class name when the input url matches the url_prefix' do
      urls = %w(sec.gov http://www.sec.gov http://www.sec.gov/archives/edgar)
      urls.each do |input_url|
        Sitelinks::Generators.matching_generator_names([input_url]).should eq([described_class.name])
      end
    end

    it 'returns empty array when the input url does not match the url_prefix' do
      urls = %w(test.sec.gov http://www.sec.gov/archives/notedgar)
      urls.each do |input_url|
        Sitelinks::Generators.matching_generator_names([input_url]).should be_empty
      end
    end
  end

  describe '.generate' do
    it 'returns [] when the input url does not match' do
      urls = %w(test.sec.gov
                www.sec.gov/Archives/edgar/data/not/number/
                http://www.sec.gov/Archives/edgar/data/123/456/ends-with-index.htm)
      urls.each do |url|
        described_class.generate(url).should be_empty
      end
    end

    it 'returns generated urls when the input url matches' do
      urls = %w(http://sec.gov/Archives/edgar/data/831001/000119312507038505/dex2101.htm
                http://www.sec.gov/Archives/edgar/data/831001/000119312507038505/dex2101.htm)
      expected_urls = [{ title: 'Full Filing',
                         url: 'http://www.sec.gov/Archives/edgar/data/831001/0001193125-07-038505-index.htm' },
                       { title: 'Most Recent Filings for this Company',
                         url: 'http://www.sec.gov/cgi-bin/browse-edgar?CIK=831001&Find=Search&action=getcompany&owner=exclude' }]

      urls.each do |url|
        described_class.generate(url).should eq(expected_urls)
      end
    end
  end
end
