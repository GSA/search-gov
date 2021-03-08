require 'spec_helper'

describe CatalogPrefix do
  fixtures :catalog_prefixes

  before do
    @valid_attributes = {:prefix => 'http://respuestas.gobiernousa.gov/system/selfservice.controller'}
  end

  describe 'Creating new instance' do
    it { is_expected.to validate_presence_of :prefix }
    it { is_expected.to validate_uniqueness_of(:prefix).case_insensitive }
    it { is_expected.not_to allow_value('foogov.gov/script').for(:prefix)}
    it { is_expected.to allow_value('http://www.foo.gov/').for(:prefix)}
    it { is_expected.to allow_value('http://foo.gov/subfolder').for(:prefix)}
  end

  describe '#label' do
    it 'should return the prefix' do
      expect(CatalogPrefix.new(:prefix => 'foo').label).to eq('foo')
    end
  end
end