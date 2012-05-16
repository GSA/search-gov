require 'spec/spec_helper'

describe CommonSubstring do
  fixtures :common_substrings, :indexed_domains, :affiliates
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

    context "when there are associated IndexedDocuments that contain the substring" do
      before do
        aff = affiliates(:power_affiliate)
        @doc1 = aff.indexed_documents.create!(:indexed_domain => indexed_domains(:sample), :url => "http://www.foo.gov/a.html", :body => "doc1 has this text in it")
        @doc2 = aff.indexed_documents.create!(:indexed_domain => indexed_domains(:sample), :url => "http://www.foo.gov/b.html", :body => "doc2 has this text in it")
        @doc3 = aff.indexed_documents.create!(:indexed_domain => indexed_domains(:sample), :url => "http://www.foo.gov/c.html", :body => "doc3 does not have this text in it")
      end

      it "should apply the change to all associated IndexedDocuments that contain the substring in the body" do
        substring = "has this text"
        indexed_domains(:sample).common_substrings.create!(:substring => substring, :saturation => 99.3)
        @doc1.reload
        @doc1.body.should == 'doc1 in it'
        @doc2.reload
        @doc2.body.should == 'doc2 in it'
        @doc3.reload
        @doc3.body.should == 'doc3 does not have this text in it'
      end
    end
  end

end
