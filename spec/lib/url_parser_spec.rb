require 'spec_helper'

describe UrlParser do
  describe '.normalize' do
    it 'should prefix URL without http:// or https:// prefix' do
      url = 'www.usa.gov'
      expect(UrlParser.normalize(url)).to eq('http://www.usa.gov/')
    end

    it 'should normalize URL' do
      url = 'https://www.USA.gov.//blog/..//NEWS releases?z=a;y=b&x=c'
      expect(UrlParser.normalize(url)).to eq('https://www.usa.gov/NEWS%20releases?z=a;y=b&x=c')
    end
  end

end
