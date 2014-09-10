require 'spec_helper'

describe DocumentCollection do
  fixtures :affiliates, :document_collections, :url_prefixes, :navigations

  before do
    @valid_attributes = {
      :name => 'My Collection',
      :affiliate => affiliates(:power_affiliate),
      :url_prefixes_attributes => {'0' => {:prefix => 'http://www.agency.gov/'}}
    }
  end

  describe "Creating new instance" do
    it { should belong_to :affiliate }
    it { should have_many(:url_prefixes).dependent(:destroy) }
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of(:name).scoped_to(:affiliate_id).case_insensitive }

    it "should create navigation" do
      dc = DocumentCollection.create!(@valid_attributes)
      dc.navigation.should == Navigation.find(dc.navigation.id)
      dc.navigation.affiliate_id.should == dc.affiliate_id
      dc.navigation.position.should == 100
      dc.navigation.should_not be_is_active
    end

    it 'should not allow document collection without prefix' do
      dc = DocumentCollection.new(@valid_attributes.except(:url_prefixes_attributes))
      dc.should_not be_valid
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
      subject.depth.should == 3
    end
  end

  describe '#assign_sitelink_generator_names!' do
    it 'assigns sitelink generator names' do
      sitelink_generator_names = %w(Sitelinks::Generators::FakeGenerator).freeze
      Sitelinks::Generators.should_receive(:matching_generator_names).
        with(%w(http://www.agency.gov/)).
        and_return(sitelink_generator_names)

      dc = DocumentCollection.create!(@valid_attributes)
      dc.assign_sitelink_generator_names!
      dc.sitelink_generator_names.should eq(sitelink_generator_names)
    end
  end
end
