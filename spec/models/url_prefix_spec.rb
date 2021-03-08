require 'spec_helper'

describe UrlPrefix do
  fixtures :document_collections, :url_prefixes, :navigations

  before do
    @valid_attributes = {
      prefix: 'http://www.foo.gov/folder',
      document_collection: document_collections(:sample)
    }
  end

  describe 'Creating new instance' do
    it { is_expected.to belong_to :document_collection }
    it { is_expected.to validate_presence_of :prefix }
    it { is_expected.to validate_uniqueness_of(:prefix).scoped_to(:document_collection_id).case_insensitive }
    it { is_expected.not_to allow_value('foogov').for(:prefix)}
    it { is_expected.to allow_value('http://www.foo.gov/').for(:prefix)}
    it { is_expected.to allow_value('https://www.foo.gov/').for(:prefix)}
    it { is_expected.to allow_value('http://foo.gov/subfolder/').for(:prefix)}

    it 'should cap prefix length at 255 characters' do
      too_long = "http://www.foo.gov/#{'waytoolong'*25}/"
      url_prefix = described_class.new(@valid_attributes.merge(prefix: too_long))
      expect(url_prefix).not_to be_valid
      expect(url_prefix.errors[:prefix].first).to match(/too long/)
    end

    it 'should validate the URL prefix against URI.parse' do
      url_prefix = described_class.new(@valid_attributes.merge(prefix: 'http://www.gov.gov/pipesare||bad/'))
      expect(url_prefix.valid?).to be false
      expect(url_prefix.errors.full_messages.first).to eq('Prefix is not a valid URL')
    end

    it 'normalizes the prefix' do
      expect(described_class.create!(@valid_attributes.merge(prefix: '    www.FOO.gov   ')).prefix).to eq('http://www.foo.gov/')
    end
  end

  describe '#label' do
    it 'should return the prefix' do
      expect(described_class.new(prefix: 'foo').label).to eq('foo')
    end
  end

  describe '#depth' do
    it 'should return the subdirectory depth of the url prefix' do
      expect(described_class.new(prefix: 'http://www.gov.gov/').depth).to eq(0)
      expect(described_class.new(prefix: 'http://www.gov.gov/owcp/').depth).to eq(1)
      expect(described_class.new(prefix: 'http://www.gov.gov/owcp/two/').depth).to eq(2)
      expect(described_class.new(prefix: 'http://www.gov.gov/owcp/two/three/').depth).to eq(3)
    end
  end

  describe '#dup' do
    let(:original_instance) { url_prefixes(:one) }

    include_examples 'dupable',
                     %w(document_collection_id)
  end
end
