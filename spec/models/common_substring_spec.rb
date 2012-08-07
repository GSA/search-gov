require 'spec_helper'

describe CommonSubstring do
  fixtures :common_substrings, :indexed_domains, :affiliates, :site_domains
  before do
    @valid_attributes = {
      :substring => 'U.S. Army Corps of Engineers',
      :saturation => 99.1,
      :indexed_domain_id => indexed_domains(:sample).id
    }
  end

  it { should belong_to :indexed_domain }
  it { should validate_presence_of :substring }
  it { should validate_presence_of :indexed_domain_id }
  it { should validate_presence_of :saturation }
  it { should validate_uniqueness_of(:substring).scoped_to(:indexed_domain_id) }

  describe "creating a new CommonSubstring" do
    it "should create a new instance given valid attributes" do
      CommonSubstring.create!(@valid_attributes)
    end

    it "should trim whitespace from substring" do
      CommonSubstring.create!(@valid_attributes.merge(:substring => " remove leading and ending spaces "))
      CommonSubstring.find_by_substring("remove leading and ending spaces").should_not be_nil
    end

    context "when there are associated IndexedDocuments that contain the substring" do
      before do
        aff = affiliates(:basic_affiliate)
        aff.features << Feature.find_or_create_by_internal_name('hosted_sitemaps', :display_name => "hs")
        @doc1 = aff.indexed_documents.create!(:indexed_domain => indexed_domains(:sample), :doctype => 'html', :url => "http://gov.nps.gov/a.html", :body => "doc1 has this text in it")
        @doc2 = aff.indexed_documents.create!(:indexed_domain => indexed_domains(:sample), :doctype => 'html', :url => "http://gov.nps.gov/b.html", :body => "doc2 has this text in it")
        @doc3 = aff.indexed_documents.create!(:indexed_domain => indexed_domains(:sample), :doctype => 'html', :url => "http://gov.nps.gov/c.html", :body => "doc3 does not have this text in it")
      end

      it "should apply the change to all associated IndexedDocuments that contain the substring in the body" do
        substring = "has this text"
        cs = indexed_domains(:sample).common_substrings.create!(:substring => substring, :saturation => 99.3)
        cs.send(:remove_from_indexed_documents)
        @doc1.reload
        @doc1.body.should == 'doc1 in it'
        @doc2.reload
        @doc2.body.should == 'doc2 in it'
        @doc3.reload
        @doc3.body.should == 'doc3 does not have this text in it'
      end
    end
  end

  describe "updating a substring" do
    it "should not try to modify the potentially frozen string instance" do
      cs = CommonSubstring.create!(@valid_attributes)
      cs.reload
      cs.substring = " frozen "
      cs.substring.freeze
      cs.save!
    end
  end

end
