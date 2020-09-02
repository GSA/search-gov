require 'spec_helper'

describe DocumentCollection do
  fixtures :affiliates, :document_collections, :url_prefixes, :navigations
  let(:affiliate) { affiliates(:power_affiliate) }
  let(:valid_attributes) do
    { :name => 'My Collection',
      :affiliate => affiliate,
      :url_prefixes_attributes => {'0' => {:prefix => 'http://www.agency.gov/'}}
    }
  end

  describe 'schema' do
    it { is_expected.to have_db_column(:advanced_search_enabled).of_type(:boolean).
         with_options(null: false, default: false) }
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

  describe "Creating new instance" do
    it "should create navigation" do
      dc = DocumentCollection.create!(valid_attributes)
      expect(dc.navigation).to eq(Navigation.find(dc.navigation.id))
      expect(dc.navigation.affiliate_id).to eq(dc.affiliate_id)
      expect(dc.navigation.position).to eq(100)
      expect(dc.navigation).not_to be_is_active
    end

    it 'should not allow document collection without prefix' do
      dc = DocumentCollection.new(valid_attributes.except(:url_prefixes_attributes))
      expect(dc).not_to be_valid
    end
  end

  describe "#depth" do
    subject do
      DocumentCollection.create!(:name => 'My Collection',
                                  :affiliate => affiliates(:power_affiliate),
                                  :url_prefixes_attributes => {'0' => {:prefix => 'http://www.agency.gov/'},
                                                               '1' => {:prefix => 'http://www.agency.gov/one/two/three/'},
                                                               '2' => {:prefix => 'http://www.agency.gov/simple/'}}
      )
    end

    it 'should return the maximum depth of its url prefixes' do
      expect(subject.depth).to eq(3)
    end
  end

  describe '#assign_sitelink_generator_names!' do
    it 'assigns sitelink generator names' do
      sitelink_generator_names = %w(SitelinkGenerator::FakeGenerator).freeze
      expect(SitelinkGeneratorUtils).to receive(:matching_generator_names).
        with(%w(http://www.agency.gov/)).
        and_return(sitelink_generator_names)

      dc = DocumentCollection.create!(valid_attributes)
      dc.assign_sitelink_generator_names!
      expect(dc.sitelink_generator_names).to eq(sitelink_generator_names)
    end
  end

  describe '#dup' do
    subject(:original_instance) { document_collections(:sample).dup }
    include_examples 'site dupable'
  end

  describe '#sitelink_generator_names_as_str' do
    let(:collection) { DocumentCollection.new(sitelink_generator_names: %w(ABC XYZ)) }

    it 'returns the names as a comma-separated string' do
      expect(collection.sitelink_generator_names_as_str).to eq 'ABC,XYZ'
    end
  end
end
