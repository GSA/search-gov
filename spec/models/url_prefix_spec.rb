require 'spec_helper'

describe UrlPrefix do
  fixtures :document_collections, :url_prefixes, :navigations

  before do
    @valid_attributes = {
      :prefix => 'http://www.foo.gov/folder',
      :document_collection => document_collections(:sample)
    }
  end

  describe "Creating new instance" do
    it { should belong_to :document_collection }
    it { should validate_presence_of :prefix }
    it { should validate_uniqueness_of(:prefix).scoped_to(:document_collection_id).case_insensitive }
    it { should_not allow_value("foogov").for(:prefix)}
    it { should allow_value("http://www.foo.gov/").for(:prefix)}
    it { should allow_value("https://www.foo.gov/").for(:prefix)}
    it { should allow_value("http://foo.gov/subfolder/").for(:prefix)}

    it 'should cap prefix length at 255 characters' do
      too_long = "http://www.foo.gov/#{'waytoolong'*25}/"
      url_prefix = UrlPrefix.new(@valid_attributes.merge(:prefix=> too_long))
      url_prefix.should_not be_valid
      url_prefix.errors[:prefix].first.should =~ /too long/
    end

    it "should validate the URL prefix against URI.parse" do
      url_prefix = UrlPrefix.new(@valid_attributes.merge(:prefix => "http://www.gov.gov/pipesare||bad/"))
      url_prefix.valid?.should be_false
      url_prefix.errors.full_messages.first.should == "Prefix is not a valid URL"
    end

    it "normalizes the prefix" do
      UrlPrefix.create!(@valid_attributes.merge(:prefix=> '    www.FOO.gov   ')).prefix.should == 'http://www.foo.gov/'
    end
  end

  describe "#label" do
    it "should return the prefix" do
      UrlPrefix.new(:prefix => "foo").label.should == "foo"
    end
  end

  describe '#depth' do
    it 'should return the subdirectory depth of the url prefix' do
      UrlPrefix.new(prefix: 'http://www.gov.gov/').depth.should == 0
      UrlPrefix.new(prefix: 'http://www.gov.gov/owcp/').depth.should == 1
      UrlPrefix.new(prefix: 'http://www.gov.gov/owcp/two/').depth.should == 2
      UrlPrefix.new(prefix: 'http://www.gov.gov/owcp/two/three/').depth.should == 3
    end
  end
end
