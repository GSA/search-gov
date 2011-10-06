require 'spec/spec_helper'

describe SuperfreshUrlToIndexedDocument, "#perform(url, affiliate_id)" do
  fixtures :affiliates, :superfresh_urls
  before do
    @aff = affiliates(:power_affiliate)
    IndexedDocument.destroy_all
  end

  context "when it can't locate the Superfresh URL entry for a given url & affiliate_id" do
    it "should quietly fail" do
      lambda { SuperfreshUrlToIndexedDocument.perform("nope", nil) }.should_not change(IndexedDocument, :count)
    end
  end

  context "when the URL points to an HTML page" do
    context "when there is a problem fetching the URL content" do
      before do
        IndexedDocument.stub!(:open).and_raise Errno::ECONNRESET
      end

      it "should log an error and exit" do
        Rails.logger.should_receive(:error).with instance_of(String)
        surl = superfresh_urls(:with_description_meta)
        SuperfreshUrlToIndexedDocument.perform(surl.url, surl.affiliate.id)
      end
    end

    context "when the page has a HTML title" do
      context "when the title is long" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm'))
          puts doc.object_id
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should use the title, truncated to 60 characters on a word boundary" do
          surl = superfresh_urls(:with_description_meta)
          lambda { SuperfreshUrlToIndexedDocument.perform(surl.url, @aff.id) }.should change(IndexedDocument, :count).by(1)
          idoc = @aff.indexed_documents.find_by_url(surl.url)
          idoc.title.should == "Fire Island National Seashore - Fire Island Light Station..."
        end
      end

      context "when the page has a description meta tag" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should use it when creating the boosted content" do
          surl = superfresh_urls(:with_description_meta)
          lambda { SuperfreshUrlToIndexedDocument.perform(surl.url, @aff.id) }.should change(IndexedDocument, :count).by(1)
          idoc = @aff.indexed_documents.find_by_url(surl.url)
          idoc.description.should == "New display building for the original Fire Island Lighthouse Fresnel lens opens"
        end

      end

      context "when the page has a differently capitalized DeScriPtioN meta tag" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23-caps.htm'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should still find it and use it" do
          surl = superfresh_urls(:with_description_meta)
          SuperfreshUrlToIndexedDocument.perform(surl.url, @aff.id)
          idoc = @aff.indexed_documents.find_by_url(surl.url)
          idoc.description.should == "New display building for the original Fire Island Lighthouse Fresnel lens opens"
        end
      end

      context "when the page does not have a description meta tag" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/data-layers.html'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should use the initial subset of non-HTML words of the web page as the description" do
          surl = superfresh_urls(:without_description_meta)
          SuperfreshUrlToIndexedDocument.perform(surl.url, @aff.id)
          idoc = @aff.indexed_documents.find_by_url(surl.url)
          idoc.title.should == "Carribean Sea Regional Atlas - Map Service and Layer..."
          idoc.description.should == "Carribean Sea Regional Atlas. -. Map Service and Layer Descriptions. Ocean Exploration and Research (OER) Digital Atlases. Caribbean Sea. Description. This map aids the public in locating surveys carried out by NOAA's Office of Exploration and..."
        end
      end
    end
  end

  context "when the URL points to a PDF" do
    before do
      @superfresh_url = superfresh_urls(:pdf)
      @raw_pdf = File.open(Rails.root.to_s + "/spec/fixtures/pdf/test.pdf")
      IndexedDocument.stub!(:open).and_return @raw_pdf
    end

    it "should open the pdf file" do
      SuperfreshUrlToIndexedDocument.perform(@superfresh_url.url, @aff.id)
    end
    
    it "should create a boosted content that has a title and description from the pdf" do
      SuperfreshUrlToIndexedDocument.perform(@superfresh_url.url, @aff.id)
      indexed_document = @aff.indexed_documents.find_by_url(@superfresh_url.url)
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
        SuperfreshUrlToIndexedDocument.perform(@superfresh_url.url, @aff.id)
        indexed_document = @aff.indexed_documents.find_by_url(@superfresh_url.url)
        indexed_document.should_not be_nil
        indexed_document.title.should == "3-2-07-III H.pdf"
      end
    end
    
    context "when some exception is raised while fetching or parsing the PDF file" do
      before do
        PDF::Toolkit.stub!(:open).and_raise "Some Error"
      end
      
      it "should log an error" do
        Rails.logger.should_receive(:error).with(/Some Error/)
        SuperfreshUrlToIndexedDocument.perform(@superfresh_url.url, @aff.id)
      end
    end
    
    context "when some exception is raised while opening the PDF file" do
      before do
        IndexedDocument.stub!(:open).and_raise 'Some Error'
      end
      
      it "should log an error" do
        Rails.logger.should_receive(:error).with(/Some Error/)
        SuperfreshUrlToIndexedDocument.perform(@superfresh_url.url, @aff.id)
      end
    end        
  end
end