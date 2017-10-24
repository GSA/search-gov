# coding: utf-8
require 'spec_helper'

describe IndexedDocument do
  fixtures :affiliates, :superfresh_urls, :site_domains, :features
  before do
    @min_valid_attributes = {
      :title => 'Some Title',
      :url => "http://min.nps.gov/link.html",
      :affiliate_id => affiliates(:basic_affiliate).id
    }
    @valid_attributes = {
      :title => 'Some Title',
      :description => 'This is a document.',
      :url => 'http://www.nps.gov/index.htm',
      :doctype => 'html',
      :last_crawl_status => IndexedDocument::OK_STATUS,
      :body => "this is the doc body",
      :affiliate_id => affiliates(:basic_affiliate).id
    }
  end

  let(:valid_attributes) do
    {
      :title => 'Some Title',
      :description => 'This is a document.',
      :url => 'http://www.nps.gov/index.htm',
      :doctype => 'html',
      :last_crawl_status => IndexedDocument::OK_STATUS,
      :body => "this is the doc body",
      :affiliate_id => affiliates(:basic_affiliate).id,
    }
  end
  it { should validate_presence_of :affiliate_id }
  it { should validate_presence_of :title }
  it { should belong_to :affiliate }

  describe "normalizing URLs when saving" do
    context "when URL doesn't have a protocol" do
      let(:url) { "www.nps.gov/sdfsdf" }
      it "should prepend it with https://" do
        IndexedDocument.create!(@valid_attributes.merge(:url => url)).url.should == "https://www.nps.gov/sdfsdf"
      end
    end
  end

  it "should create a SuperfreshUrl entry for the affiliate" do
    SuperfreshUrl.find_by_url_and_affiliate_id(@min_valid_attributes[:url], @min_valid_attributes[:affiliate_id]).should be_nil
    IndexedDocument.create!(@min_valid_attributes)
    SuperfreshUrl.find_by_url_and_affiliate_id(@min_valid_attributes[:url], @min_valid_attributes[:affiliate_id]).should_not be_nil
  end

  it "should validate unique url" do
    IndexedDocument.create!(@valid_attributes)
    duplicate = IndexedDocument.new(@valid_attributes.merge(:url => @valid_attributes[:url].upcase))
    duplicate.should_not be_valid
    duplicate.errors[:url].first.should =~ /already been added/
  end

  it "should allow a duplicate url for a different affiliate" do
    IndexedDocument.create!(@valid_attributes)
    affiliates(:power_affiliate).site_domains.create!(:domain => affiliates(:basic_affiliate).site_domains.first.domain)
    duplicate = IndexedDocument.new(@valid_attributes.merge(:affiliate_id => affiliates(:power_affiliate).id))
    duplicate.should be_valid
  end

  it "should not allow setting last_crawl_status to OK if the title is blank" do
    odie = IndexedDocument.create!(@min_valid_attributes)
    odie.update_attributes(:title => nil, :description => 'bogus description', :last_crawl_status => IndexedDocument::OK_STATUS).should be false
    odie.errors[:title].first.should =~ /can't be blank/
  end

  describe "#fetch" do

    let(:indexed_document) { IndexedDocument.create!(@valid_attributes) }

    it "should set the load time attribute" do
      indexed_document.url = 'https://search.digitalgov.gov/'
      indexed_document.fetch
      indexed_document.reload
      indexed_document.load_time.should_not be_nil
    end

    context "when there is a problem fetching and indexing the URL content" do
      before do
        stub_request(:get, indexed_document.url).to_return(status: [301, 'Moved Permanently'])
      end

      it "should update the url with last crawled date and error message and set the body to nil" do
        indexed_document.fetch
        indexed_document.last_crawled_at.should_not be_nil
        indexed_document.last_crawl_status.should == "301 Moved Permanently"
        indexed_document.body.should be_nil
        indexed_document.description.should == 'This is a document.'
        indexed_document.title.should == 'Some Title'
      end
    end

    context "when there is a problem updating the attributes after catching an exception during indexing" do
      before do
        Net::HTTP.stub(:start).and_raise Exception.new("some problem during indexing")
        indexed_document.stub(:update_attributes!).and_raise Timeout::Error
      end

      it "should handle the exception and delete the record" do
        indexed_document.fetch
        IndexedDocument.find_by_id(indexed_document.id).should be_nil
      end

      context "when there is a problem destroying the record" do
        before do
          indexed_document.stub(:destroy).and_raise Exception.new("Some other problem")
        end

        it "should fail gracefully" do
          Rails.logger.should_receive(:warn)
          indexed_document.fetch
        end

      end
    end
  end

  describe "#save_or_destroy" do
    before do
      @indexed_document = IndexedDocument.create!(@valid_attributes)
    end

    context "when Rails validation misses that it's a duplicate and MySQL throws an exception" do
      before do
        @indexed_document.stub(:save!).and_raise(Mysql2::Error.new("oops"))
      end

      it "should catch the exception and delete the record" do
        @indexed_document.save_or_destroy
        IndexedDocument.find_by_id(@indexed_document.id).should be_nil
      end
    end

    context 'when record is invalid' do
      before do
        @indexed_document.stub(:save!).and_raise(ActiveRecord::RecordInvalid.new(@indexed_document))
      end

      it 'should raise IndexedDocumentError' do
        lambda { @indexed_document.save_or_destroy }.should raise_error(IndexedDocument::IndexedDocumentError, "Problem saving indexed document: record invalid")
      end
    end
  end

  describe "#index_document(file, content_type)" do
    before do
      @indexed_document = IndexedDocument.create!(@min_valid_attributes)
      @file = open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm')
    end

    context "when the fetched document is a PDF doc" do
      before do
        @file.stub(:content_type).and_return 'application/pdf'
      end

      it "should call index_application_file with 'pdf'" do
        @indexed_document.should_receive(:index_application_file).with(@file.path, 'pdf').and_return true
        @indexed_document.index_document(@file, @file.content_type)
      end
    end

    context "when the fetched document is a Word doc" do
      before do
        @file.stub(:content_type).and_return 'application/msword'
      end

      it "should call index_application_file with 'word'" do
        @indexed_document.should_receive(:index_application_file).with(@file.path, 'word').and_return true
        @indexed_document.index_document(@file, @file.content_type)
      end
    end

    context "when the fetched document is a Powerpoint doc" do
      before do
        @file.stub(:content_type).and_return 'application/ms-powerpoint'
      end

      it "should call index_application_file with 'ppt'" do
        @indexed_document.should_receive(:index_application_file).with(@file.path, 'ppt').and_return true
        @indexed_document.index_document(@file, @file.content_type)
      end
    end

    context "when the fetched document is an Excel doc" do
      before do
        @file.stub(:content_type).and_return 'application/ms-excel'
      end

      it "should call index_application_file with 'excel'" do
        @indexed_document.should_receive(:index_application_file).with(@file.path, 'excel').and_return true
        @indexed_document.index_document(@file, @file.content_type)
      end
    end

    context "when the content type of the fetched document contains 'html'" do
      it "should call index_html" do
        @indexed_document.should_receive(:index_html).with(@file).and_return true
        @indexed_document.index_document(@file, 'text/html')
      end
    end

    context "when the content type of the fetched document is unknown" do
      before do
        @file.stub(:content_type).and_return 'application/clipart'
      end

      it "should raise an IndexedDocumentError error indicating that the document type is not yet supported" do
        lambda { @indexed_document.index_document(@file, @file.content_type) }.should raise_error(IndexedDocument::IndexedDocumentError, "Unsupported document type: application/clipart")
      end
    end

    context "when the document is too big" do
      before do
        @file.stub(:size).and_return IndexedDocument::MAX_DOC_SIZE+1
      end

      it "should raise an IndexedDocumentError error indicating that the document is too big" do
        lambda { @indexed_document.index_document(@file, @file.content_type) }.should raise_error(IndexedDocument::IndexedDocumentError, "Document is over 50mb limit")
      end
    end
  end

  describe "#index_html(file)" do
    context "when the page has a HTML title" do
      let(:indexed_document) { IndexedDocument.create!(@min_valid_attributes) }
      let(:file) { open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm') }

      it "should extract the text body from the document" do
        indexed_document.should_receive(:extract_body_from).and_return "this is the body"
        indexed_document.index_html open(Rails.root.to_s + '/spec/fixtures/html/data-layers.html')
        indexed_document.body.should == "this is the body"
      end

      context "when the page body (inner text) is empty" do
        before do
          indexed_document.stub(:scrub_inner_text)
        end

        it "should raise an IndexedDocumentError" do
          lambda { indexed_document.index_html(file) }.should raise_error(IndexedDocument::IndexedDocumentError)
        end
      end

    end
  end

  describe "#extract_body_from(nokogiri_doc)" do
    let(:doc) { Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/usa_gov/audiences.html')) }

    it "should return the inner text of the body of the document" do
      indexed_document = IndexedDocument.new(:url => "http://gov.nps.gov/page.html")
      body = indexed_document.extract_body_from(doc)
      body.should == "Skip to Main Content Home FAQs Site Index E-mail Us Chat Get E-mail Updates Change Text Size Español Search 1 (800) FED-INFO|1 (800) 333-4636 Get Services Get It Done Online! Public Engagement Performance Dashboards Shop Government Auctions Replace Vital Records MORE SERVICES Government Jobs Change Your Address Explore Topics Jobs and Education Family, Home, and Community Public Safety and Law Health and Nutrition Travel and Recreation Money and Taxes Environment, Energy, and Agriculture Benefits and Grants Defense and International Consumer Guides Reference and General Government History, Arts, and Culture Voting and Elections Science and Technology Audiences Audiences Find Government Agencies All Government A-Z Index of the U.S. Government Federal Government Executive Branch Judicial Branch Legislative Branch State, Local, and Tribal State Government Local Government Tribal Government Contact Government U.S. Congress & White House Contact Government Elected Officials Agency Contacts Contact Us FAQs MORE CONTACTS Governor and State Legislators E-mail Print Share RSS You Are Here Home &gt; Citizens &gt; Especially for Specific Audiences Especially for Specific Audiences Removed the links here, too. This is the last page for the test, with dead ends on the breadcrumb, too Contact Your Government FAQs E-mail Us Chat Phone Page Last Reviewed or Updated: October 28, 2010 Connect with Government Facebook Twitter Mobile YouTube Our Blog Home About Us Contact Us Website Policies Privacy Suggest-A-Link Link to Us USA.gov is the U.S. government's official web portal."
    end
  end

  describe "#index_application_file(file)" do
    let(:indexed_document) { IndexedDocument.create!(@min_valid_attributes.merge(title: 'preset title', description: 'preset description')) }

    context "for a normal application file (PDF/Word/PPT/Excel)" do
      before do
        indexed_document.index_application_file(Rails.root.to_s + "/spec/fixtures/pdf/test.pdf", 'pdf')
      end

      it "should update the body of the indexed document, leaving title field and description intact" do
        indexed_document.id.should_not be_nil
        indexed_document.body.should == "This is my headline. This is my content. This is a test PDF file, we are use it to test our PDF parsing technology. We want it to be at least 250 characters long so that we can test the description generator and see that it cuts off the description, meaning truncates it, in the right location. It should truncate the text and cut off the following: truncate me. It includes some special characters to test our parsing: m–dash, “curly quotes”, a’postrophe, paragraph: ¶"
        indexed_document.description.should == 'preset description'
        indexed_document.title.should == 'preset title'
        indexed_document.url.should == @min_valid_attributes[:url]
      end

      it "should set the the time and status from the crawl" do
        indexed_document.last_crawled_at.should_not be_nil
        indexed_document.last_crawl_status.should == IndexedDocument::OK_STATUS
      end
    end

    context "when the page content is empty" do
      before do
        indexed_document.stub(:parse_file).and_return ""
      end

      it "should raise an IndexedDocumentError" do
        lambda { indexed_document.index_application_file(Rails.root.to_s + "/spec/fixtures/pdf/test.pdf", 'pdf') }.should raise_error(IndexedDocument::IndexedDocumentError)
      end
    end
  end

  describe '.by_matching_url(query)' do
    context 'when url field has substring match' do
      before do
        @affiliate = affiliates(:basic_affiliate)
        one = IndexedDocument.create!(:url => 'http://nps.gov/url1.html', :last_crawled_at => Time.now, :affiliate => @affiliate, :title => 'Some document Title', :description => 'This is a document.')
        two = IndexedDocument.create!(:url => 'http://nps.gov/url2.html', :last_crawled_at => Time.now, :affiliate => @affiliate, :title => 'Another Title', :description => 'This is also a document.')
        IndexedDocument.create!(:url => 'http://anotheraffiliate.mil', :last_crawled_at => Time.now, :affiliate => @affiliate, :title => 'Third Title', :description => 'This is the last document.')
        @array = [one, two]
      end

      it 'should find the records' do
        matches = @affiliate.indexed_documents.by_matching_url('nps.gov')
        matches.size.should == 2
        matches.should match_array(@array)
      end
    end

  end

  describe "#normalize_error_message(e)" do
    context "when it's a timeout-related error" do
      it "should return 'Document took too long to fetch'" do
        indexed_document = IndexedDocument.new
        e = Exception.new('this is because execution expired')
        indexed_document.send(:normalize_error_message, e).should == 'Document took too long to fetch'
      end
    end

    context "when it's a protocol redirection-related error" do
      it "should return 'Redirection forbidden from HTTP to HTTPS'" do
        indexed_document = IndexedDocument.new
        e = Exception.new('redirection forbidden from this to that')
        indexed_document.send(:normalize_error_message, e).should == 'Redirection forbidden from HTTP to HTTPS'
      end
    end

    context "when it's an uncaught Mysql-related duplicate content error" do
      it "should return 'Content hash is not unique: Identical content (title and body) already indexed'" do
        indexed_document = IndexedDocument.new
        e = Exception.new('Mysql2::Error: Duplicate entry blah blah blah')
        indexed_document.send(:normalize_error_message, e).should == 'Content hash is not unique: Identical content (title and body) already indexed'
      end
    end

    context "when it's a generic error" do
      it "should return the error message" do
        indexed_document = IndexedDocument.new
        e = Exception.new('something awful happened')
        indexed_document.send(:normalize_error_message, e).should == 'something awful happened'
      end
    end
  end

  describe '#dup' do
    subject(:original_instance) { IndexedDocument.create!(@min_valid_attributes) }
    include_examples 'site dupable'
  end

  it_should_behave_like 'a record with a fetchable url'
end
