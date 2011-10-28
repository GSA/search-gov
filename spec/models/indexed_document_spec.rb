require 'spec/spec_helper'

describe IndexedDocument do
  fixtures :affiliates, :superfresh_urls
  before do
    @min_valid_attributes = {
      :url => "http://min.usa.gov/link.html",
      :affiliate_id => affiliates(:basic_affiliate).id
    }
    @valid_attributes = {
      :title => 'PDF Title',
      :description => 'This is a PDF document.',
      :url => 'http://something.gov/pdf.pdf',
      :keywords => 'pdf,usa',
      :affiliate_id => affiliates(:basic_affiliate).id
    }
  end

  it { should validate_presence_of :url }
  it { should validate_presence_of :affiliate_id }
  it { should allow_value("http://some.site.gov/url").for(:url) }
  it { should allow_value("http://some.site.mil/url").for(:url) }
  it { should allow_value("http://some.govsite.com/url").for(:url) }
  it { should allow_value("http://some.govsite.us/url").for(:url) }
  it { should allow_value("http://some.govsite.info/url").for(:url) }
  it { should belong_to :affiliate }

  it "should create a new instance given valid attributes" do
    IndexedDocument.create!(@valid_attributes)
  end

  it "should enqueue the creation of a BoostedContent entry via Resque" do
    ResqueSpec.reset!
    indexed_document = IndexedDocument.create!(@min_valid_attributes)
    IndexedDocumentFetcher.should have_queued(indexed_document.id)
  end
  
  it "should create a SuperfreshUrl entry for the affiliate" do
    SuperfreshUrl.find_by_url_and_affiliate_id(@min_valid_attributes[:url], @min_valid_attributes[:affiliate_id]).should be_nil
    IndexedDocument.create!(@min_valid_attributes)
    SuperfreshUrl.find_by_url_and_affiliate_id(@min_valid_attributes[:url], @min_valid_attributes[:affiliate_id]).should_not be_nil
  end

  it "should validate unique url" do
    IndexedDocument.create!(@valid_attributes)
    duplicate = IndexedDocument.new(@valid_attributes)
    duplicate.should_not be_valid
    duplicate.errors[:url].first.should =~ /already been added/
  end

  it "should allow a duplicate url for a different affiliate" do
    IndexedDocument.create!(@valid_attributes)
    duplicate = IndexedDocument.new(@valid_attributes.merge(:affiliate_id => affiliates(:power_affiliate).id))
    duplicate.should be_valid
  end

  it "should allow nil keywords" do
    IndexedDocument.create!(@valid_attributes.merge(:keywords => nil))
  end

  it "should allow an empty keywords value" do
    IndexedDocument.create!(@valid_attributes.merge(:keywords => ""))
  end

  describe "#search_for" do
    before do
      @affiliate = affiliates(:basic_affiliate)
    end

    context "when the term is not mentioned in the description" do
      before do
        @pdf_document = IndexedDocument.create!(@valid_attributes)
        Sunspot.commit
        IndexedDocument.reindex
      end

      it "should find a PDF by keyword" do
        search = IndexedDocument.search_for('usa', @affiliate)
        search.total.should == 1
        search.results.first.should == @pdf_document
      end
    end

    context "when the affiliate is specified" do
      it "should instrument the call to Solr with the proper action.service namespace, affiliate, and query param hash" do
        ActiveSupport::Notifications.should_receive(:instrument).
          with("solr_search.usasearch", hash_including(:query => hash_including(:affiliate => @affiliate.name, :model=>"IndexedDocument", :term => "foo")))
        IndexedDocument.search_for('foo', @affiliate)
      end
    end
  end

  describe "#fetch" do
    before do
      File.stub!(:delete)
    end

    let(:indexed_document) { IndexedDocument.create!(@min_valid_attributes) }

    context "when there is a problem fetching the URL content" do
      before do
        indexed_document.stub!(:open).and_raise Exception.new("ERROR!")
      end

      it "should update the url with last crawled date and error message" do
        indexed_document.fetch
        indexed_document.last_crawled_at.should_not be_nil
        indexed_document.last_crawl_status.should == "Error"
      end

      it "should not attempt to clean up the nil file descriptor" do
        File.should_not_receive(:delete)
        indexed_document.fetch
      end
    end

    context "when the URL ends in PDF" do
      before do
        indexed_document.url = 'http://something.gov/something.pdf'
        @pdf_io = StringIO.new(File.read(Rails.root.to_s + "/spec/fixtures/pdf/test.pdf"))
        indexed_document.stub!(:open).and_return @pdf_io
        @tempfile = Tempfile.new(Time.now.to_s)
        Tempfile.stub!(:new).and_return @tempfile
      end

      it "should call index_pdf" do
        indexed_document.should_receive(:index_pdf).with(@tempfile.path)
        indexed_document.fetch
      end

      it "should delete the downloaded temporary PDF file" do
        File.should_receive(:delete)
        indexed_document.fetch
      end      
    end

    context "when the URL doesn't end in PDF" do
      before do
        indexed_document.url = 'http://something.gov/something.html'
        @html_io = open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm')
        indexed_document.stub!(:open).and_return @html_io
      end
      
      it "should not try to create a tempfile" do
        Tempfile.should_not_receive(:new)
      end

      it "should call fetch_html" do
        indexed_document.should_receive(:index_html).with(@html_io)
        indexed_document.fetch
      end

      it "should delete the downloaded temporary HTML file" do
        File.should_receive(:delete).with(@html_io)
        indexed_document.fetch
      end
    end
  end

  describe "#index_html(file)" do
    context "when the page has a HTML title" do
      before do
        @indexed_document = IndexedDocument.create!(@min_valid_attributes)
        file = open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm')
        @indexed_document.index_html(file)
      end

      context "when the title is long" do
        it "should use the title, truncated to 60 characters on a word boundary" do
          @indexed_document.title.should == "Fire Island National Seashore - Fire Island Light Station..."
        end
      end

      context "when the page has a description meta tag" do
        it "should use it when creating the boosted content" do
          @indexed_document.description.should == "New display building for the original Fire Island Lighthouse Fresnel lens opens"
        end
      end

      context "when the page has a differently capitalized DeScriPtioN meta tag" do
        it "should still find it and use it" do
          @indexed_document.description.should == "New display building for the original Fire Island Lighthouse Fresnel lens opens"
        end
      end

      context "when the page does not have a description meta tag" do
        before do
          @indexed_document.index_html open(Rails.root.to_s + '/spec/fixtures/html/data-layers.html')
        end

        it "should use the initial subset of non-HTML words of the web page as the description" do
          @indexed_document.title.should == "Carribean Sea Regional Atlas - Map Service and Layer..."
          @indexed_document.description.should == "Carribean Sea Regional Atlas. -. Map Service and Layer Descriptions. Ocean Exploration and Research (OER) Digital Atlases. Caribbean Sea. Description. This map aids the public in locating surveys carried out by NOAA's Office of Exploration and..."
        end
      end
    end
  end

  describe "#index_pdf(file)" do
    context "for a normal PDF file" do
      before do
        @indexed_document = IndexedDocument.create!(@min_valid_attributes)
        file = open(Rails.root.to_s + "/spec/fixtures/pdf/test.pdf")
        @indexed_document.index_pdf(file)
      end

      it "should create an indexed document that has a title and description from the pdf" do
        @indexed_document.id.should_not be_nil
        @indexed_document.title.should == "This is a test PDF to test our PDF parsing"
        @indexed_document.description.should == "This is a test PDF to test our PDF parsing.\n\n\f"
        @indexed_document.url.should == @min_valid_attributes[:url]
      end
      
      it "should set the the time and status from the crawl" do
        @indexed_document.last_crawled_at.should_not be_nil
        @indexed_document.last_crawl_status.should == "OK"
      end
    end

    context "when the pdf body is blank" do
      before do
        @indexed_document = IndexedDocument.create!(@min_valid_attributes.merge(:url => 'http://www.state.nj.us/bpu/pdf/boardorders/3-2-07-III%20H.pdf'))
        @indexed_document.index_pdf open(Rails.root.to_s + "/spec/fixtures/pdf/badtitle.pdf")
      end

      it "should generate a title using the last part of the filename" do
        @indexed_document.id.should_not be_nil
        @indexed_document.title.should == "3-2-07-III H.pdf"
      end
    end
  end

  describe "#uncrawled_urls" do
    before do
      IndexedDocument.destroy_all
      @affiliate = affiliates(:basic_affiliate)
      @first_uncrawled_url = IndexedDocument.create!(:url => 'http://some.mil/', :affiliate => @affiliate)
      @last_uncrawled_url = IndexedDocument.create!(:url => 'http://another.mil', :affiliate => @affiliate)
      @other_affiliate_uncrawled_url = IndexedDocument.create!(:url => 'http://other.mil', :affiliate => affiliates(:power_affiliate))
      @already_crawled_url = IndexedDocument.create!(:url => 'http://already.crawled.mil', :affiliate => @affiliate, :last_crawled_at => Time.now)
    end

    context "when looking up uncrawled URLs" do
      it "should limit the number of URLs returned if specified" do
        IndexedDocument.should_receive(:find_all_by_last_crawled_at_and_affiliate_id).with(nil, @affiliate.id, {:limit => 500, :order => 'created_at asc'}).and_return []
        IndexedDocument.uncrawled_urls(@affiliate, 500)
      end

      it "should not limit the number of URLs returned if the value is not specified" do
        IndexedDocument.should_receive(:find_all_by_last_crawled_at_and_affiliate_id).with(nil, @affiliate.id, {:order => 'created_at asc'}).and_return []
        IndexedDocument.uncrawled_urls(@affiliate)
      end

      it "should return all the uncrawled urls (i.e. where crawled_at == nil) for an affiliate, ordered by created time ascending" do
        uncrawled_urls = IndexedDocument.uncrawled_urls(@affiliate)
        uncrawled_urls.size.should == 2
        uncrawled_urls.first.should == @first_uncrawled_url
        uncrawled_urls.last.should == @last_uncrawled_url
        uncrawled_urls.include?(@already_crawled_url).should be_false
        uncrawled_urls.include?(@other_affiliate_uncrawled_url).should be_false
      end
    end
  end

  describe "#crawled_urls" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @first_crawled_url = IndexedDocument.create!(:url => 'http://crawled.mil', :last_crawled_at => Time.now, :affiliate => @affiliate)
      @last_crawled_url = IndexedDocument.create!(:url => 'http://another.crawled.mil', :last_crawled_at => Time.now, :affiliate => @affiliate)
      IndexedDocument.create!(:url => 'http://anotheraffiliate.mil', :last_crawled_at => Time.now, :affiliate => affiliates(:power_affiliate))
    end

    it "should return the first page of all crawled urls" do
      crawled_urls = IndexedDocument.crawled_urls(@affiliate)
      crawled_urls.size.should == 2
      crawled_urls.include?(@first_crawled_url).should be_true
      crawled_urls.include?(@last_crawled_url).should be_true
    end

    it "should paginate the results if the page is passed in" do
      crawled_urls = IndexedDocument.crawled_urls(@affiliate, 2)
      crawled_urls.size.should == 0
    end
  end

  describe "#process_file" do
    before do
      @affiliate = affiliates(:basic_affiliate)
    end

    context "when a file is passed in with 100 or fewer URLs" do
      before do
        @urls = ['http://search.usa.gov', 'http://usa.gov', 'http://data.gov']
        tempfile = Tempfile.new('urls.txt')
        @urls.each do |url|
          tempfile.write(url + "\n")
        end
        tempfile.close
        tempfile.open
        @file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile)
      end

      it "should create a new IndexedDocument for each of the lines in the file" do
        IndexedDocument.process_file(@file, @affiliate)
        @urls.each { |url| IndexedDocument.find_by_url_and_affiliate_id(url, @affiliate.id).should_not be_nil }
      end
    end

    context "when a file is passed in with more than 100 URLs" do
      before do
        tempfile = Tempfile.new('too_many_urls.txt')
        101.times { |x| tempfile.write("http://search.usa.gov/#{x}\n") }
        tempfile.close
        tempfile.open
        @file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile)
      end

      it "should raise an error that there are too many URLs in the file" do
        lambda { IndexedDocument.process_file(@file, @affiliate) }.should raise_error('Too many URLs in your file.  Please limit your file to 100 URLs.')
      end

      context "when a max number of URLs is passed that is greater than the default max" do
        it "should allow all of the urls" do
          lambda { IndexedDocument.process_file(@file, nil, 1000) }.should_not raise_error('Too many URLs in your file.  Please limit your file to 100 URLs.')
        end
      end
    end
  end
end