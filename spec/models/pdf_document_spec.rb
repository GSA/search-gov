require 'spec/spec_helper'

describe PdfDocument do
  fixtures :affiliates
  before do
    @valid_attributes = {
      :title => 'PDF Title',
      :description => 'This is a PDF document.',
      :url => 'http://something.gov/pdf.pdf',
      :keywords => 'pdf,usa',
      :affiliate_id => affiliates(:basic_affiliate).id
    }
  end
  
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :url }
  it { should validate_presence_of :affiliate_id }
  it { should belong_to :affiliate }

  it "should create a new instance given valid attributes" do
    PdfDocument.create!(@valid_attributes)
  end

  it "should validate unique url" do
    PdfDocument.create!(@valid_attributes)
    duplicate = PdfDocument.new(@valid_attributes)
    duplicate.should_not be_valid
    duplicate.errors[:url].first.should =~ /already been added/
  end

  it "should allow a duplicate url for a different affiliate" do
    doc = PdfDocument.create!(@valid_attributes)
    duplicate = PdfDocument.new(@valid_attributes.merge(:affiliate_id => affiliates(:power_affiliate).id))
    puts duplicate.valid?
    duplicate.should be_valid
  end

  it "should allow nil keywords" do
    PdfDocument.create!(@valid_attributes.merge(:keywords => nil))
  end

  it "should allow an empty keywords value" do
    PdfDocument.create!(@valid_attributes.merge(:keywords => ""))
  end
  
  describe "#search_for" do
    before do
      @affiliate = affiliates(:basic_affiliate)
    end

    context "when the term is not mentioned in the description" do
      before do
        @pdf_document = PdfDocument.create!(@valid_attributes)
        Sunspot.commit
        PdfDocument.reindex
      end

      it "should find a PDF by keyword" do
        search = PdfDocument.search_for('usa', @affiliate)
        search.total.should == 1
        search.results.first.should == @pdf_document
      end
    end

    context "when the affiliate is specified" do
      it "should instrument the call to Solr with the proper action.service namespace, affiliate, and query param hash" do
        ActiveSupport::Notifications.should_receive(:instrument).
          with("solr_search.usasearch", hash_including(:query => hash_including(:affiliate => @affiliate.name, :model=>"PdfDocument", :term => "foo")))
        PdfDocument.search_for('foo', @affiliate)
      end
    end
  end
end