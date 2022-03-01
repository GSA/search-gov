require 'spec_helper'

describe DocumentCollection do
  fixtures :affiliates, :document_collections, :url_prefixes, :navigations
  let(:affiliate) { affiliates(:power_affiliate) }
  let(:valid_attributes) do
    { name: 'My Collection',
      affiliate: affiliate,
      url_prefixes_attributes: {'0' => {prefix: 'http://www.agency.gov/'}}
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:affiliate_id).case_insensitive }
  end

  describe 'associations' do
    it { is_expected.to belong_to :affiliate }
    it do
      is_expected.to have_many(:url_prefixes).
        dependent(:destroy).inverse_of(:document_collection)
    end
  end

  describe 'Creating new instance' do
    it 'should create navigation' do
      dc = described_class.create!(valid_attributes)
      expect(dc.navigation).to eq(Navigation.find(dc.navigation.id))
      expect(dc.navigation.affiliate_id).to eq(dc.affiliate_id)
      expect(dc.navigation.position).to eq(100)
      expect(dc.navigation).not_to be_is_active
    end

    it 'should not allow document collection without prefix' do
      dc = described_class.new(valid_attributes.except(:url_prefixes_attributes))
      expect(dc).not_to be_valid
    end
  end

  describe '#depth' do
    subject do
      described_class.create!(name: 'My Collection',
                                  affiliate: affiliates(:power_affiliate),
                                  url_prefixes_attributes: {'0' => {prefix: 'http://www.agency.gov/'},
                                                               '1' => {prefix: 'http://www.agency.gov/one/two/three/'},
                                                               '2' => {prefix: 'http://www.agency.gov/simple/'}}
      )
    end

    it 'should return the maximum depth of its url prefixes' do
      expect(subject.depth).to eq(3)
    end
  end

  describe '#dup' do
    subject(:original_instance) { document_collections(:sample).dup }
    include_examples 'site dupable'
  end
end
