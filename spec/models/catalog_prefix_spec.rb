require 'spec/spec_helper'

describe CatalogPrefix do
  fixtures :catalog_prefixes

  before do
    @valid_attributes = {:prefix => 'http://respuestas.gobiernousa.gov/system/selfservice.controller'}
  end

  describe "Creating new instance" do
    it { should validate_presence_of :prefix }
    it { should validate_uniqueness_of(:prefix) }
    it { should_not allow_value("foogov.gov/script").for(:prefix)}
    it { should allow_value("http://www.foo.gov/").for(:prefix)}
    it { should allow_value("http://foo.gov/subfolder").for(:prefix)}

  end

  describe "#label" do
    it "should return the prefix" do
      CatalogPrefix.new(:prefix => "foo").label.should == "foo"
    end
  end
end