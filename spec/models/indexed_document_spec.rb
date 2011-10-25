require 'spec/spec_helper'

describe IndexedDocument do
  fixtures :affiliates, :superfresh_urls
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
    IndexedDocument.create!(@valid_attributes)
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

  describe "#fetch(url, affiliate_id)" do
    context "when there is a problem fetching the URL content" do
      before do
        IndexedDocument.stub!(:open).and_raise Errno::ECONNRESET
      end

      it "should log an error and exit" do
        Rails.logger.should_receive(:error).with instance_of(String)
        surl = superfresh_urls(:with_description_meta)
        IndexedDocument.fetch(surl.url, surl.affiliate.id)
      end
    end

    context "when the URL ends in PDF" do
      it "should call fetch_pdf with the url and affiliate_id" do
        surl = superfresh_urls(:pdf)
        IndexedDocument.should_receive(:fetch_pdf).with(surl.url, surl.affiliate.id)
        IndexedDocument.fetch(surl.url, surl.affiliate.id)
      end
    end

    context "when the URL doesn't end in PDF" do
      it "should call fetch_html with the url and affiliate_id" do
        surl = superfresh_urls(:with_description_meta)
        IndexedDocument.should_receive(:fetch_html).with(surl.url, surl.affiliate.id)
        IndexedDocument.fetch(surl.url, surl.affiliate.id)
      end
    end
  end

  describe "#fetch_html(url, affiliate_id)" do

    context "when the page has a HTML title" do
      context "when the title is long" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should use the title, truncated to 60 characters on a word boundary" do
          surl = superfresh_urls(:with_description_meta)
          lambda { IndexedDocument.fetch_html(surl.url, surl.affiliate.id) }.should change(IndexedDocument, :count).by(1)
          surl.affiliate.indexed_documents.find_by_url(surl.url).title.should == "Fire Island National Seashore - Fire Island Light Station..."
        end
      end

      context "when the page has a description meta tag" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should use it when creating the boosted content" do
          surl = superfresh_urls(:with_description_meta)
          lambda { IndexedDocument.fetch_html(surl.url, surl.affiliate.id) }.should change(IndexedDocument, :count).by(1)
          surl.affiliate.indexed_documents.find_by_url(surl.url).description.should == "New display building for the original Fire Island Lighthouse Fresnel lens opens"
        end

      end

      context "when the page has a differently capitalized DeScriPtioN meta tag" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23-caps.htm'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should still find it and use it" do
          surl = superfresh_urls(:with_description_meta)
          IndexedDocument.fetch_html(surl.url, surl.affiliate.id)
          surl.affiliate.indexed_documents.find_by_url(surl.url).description.should == "New display building for the original Fire Island Lighthouse Fresnel lens opens"
        end
      end

      context "when the page does not have a description meta tag" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/data-layers.html'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should use the initial subset of non-HTML words of the web page as the description" do
          surl = superfresh_urls(:without_description_meta)
          IndexedDocument.fetch_html(surl.url, surl.affiliate.id)
          idoc = surl.affiliate.indexed_documents.find_by_url(surl.url)
          idoc.title.should == "Carribean Sea Regional Atlas - Map Service and Layer..."
          idoc.description.should == "Carribean Sea Regional Atlas. -. Map Service and Layer Descriptions. Ocean Exploration and Research (OER) Digital Atlases. Caribbean Sea. Description. This map aids the public in locating surveys carried out by NOAA's Office of Exploration and..."
        end
      end
    end
  end

  describe "#fetch_pdf(url, affiliate_id)" do
    before do
      @superfresh_url = superfresh_urls(:pdf)
      @raw_pdf = File.open(Rails.root.to_s + "/spec/fixtures/pdf/test.pdf")
      IndexedDocument.stub!(:open).and_return @raw_pdf
    end

    it "should open the pdf file" do
      IndexedDocument.fetch_pdf(@superfresh_url.url, @superfresh_url.affiliate.id)
    end

    it "should create an indexed document that has a title and description from the pdf" do
      IndexedDocument.fetch_pdf(@superfresh_url.url, @superfresh_url.affiliate.id)
      indexed_document = @superfresh_url.affiliate.indexed_documents.find_by_url(@superfresh_url.url)
      indexed_document.should_not be_nil
      indexed_document.title.should == "This is a test PDF to test our PDF parsing"
      indexed_document.description.should == "This is a test PDF to test our PDF parsing.\n\n\f"
      indexed_document.url.should == @superfresh_url.url
    end

    context "when the pdf body is blank" do
      before do
        @raw_pdf = File.open(Rails.root.to_s + "/spec/fixtures/pdf/badtitle.pdf")
        IndexedDocument.stub!(:open).and_return @raw_pdf
      end

      it "should generate a title using the last part of the filename" do
        IndexedDocument.fetch_pdf(@superfresh_url.url, @superfresh_url.affiliate.id)
        indexed_document = @superfresh_url.affiliate.indexed_documents.find_by_url(@superfresh_url.url)
        indexed_document.should_not be_nil
        indexed_document.title.should == "3-2-07-III H.pdf"
      end
    end
  end
end