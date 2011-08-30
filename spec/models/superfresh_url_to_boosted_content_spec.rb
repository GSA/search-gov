require 'spec/spec_helper'

describe SuperfreshUrlToBoostedContent, "#perform(url, affiliate_id)" do
  fixtures :affiliates, :superfresh_urls
  before do
    @aff = affiliates(:power_affiliate)
    BoostedContent.delete_all
  end

  context "when it can't locate the Superfresh URL entry for a given url & affiliate_id" do
    it "should quietly fail" do
      lambda { SuperfreshUrlToBoostedContent.perform("nope", nil) }.should_not change(BoostedContent, :count)
    end
  end

  context "when the URL points to an HTML page" do
    context "when there is a problem fetching the URL content" do
      before do
        SuperfreshUrlToBoostedContent.stub!(:open).and_raise Errno::ECONNRESET
      end

      it "should log an error and exit" do
        Rails.logger.should_receive(:error).with instance_of(String)
        surl = superfresh_urls(:with_description_meta)
        SuperfreshUrlToBoostedContent.perform(surl.url, surl.affiliate.id)
      end
    end

    context "when the page has a HTML title" do
      context "when the title is long" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should use the title, truncated to 60 characters on a word boundary" do
          surl = superfresh_urls(:with_description_meta)
          lambda { SuperfreshUrlToBoostedContent.perform(surl.url, @aff.id) }.should change(BoostedContent, :count).by(1)

          bc = @aff.boosted_contents.find_by_url(surl.url)
          bc.title.should == "Fire Island National Seashore - Fire Island Light Station..."
        end
      end

      context "when the page has a description meta tag" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should use it when creating the boosted content" do
          surl = superfresh_urls(:with_description_meta)
          lambda { SuperfreshUrlToBoostedContent.perform(surl.url, @aff.id) }.should change(BoostedContent, :count).by(1)

          bc = @aff.boosted_contents.find_by_url(surl.url)
          bc.description.should == "New display building for the original Fire Island Lighthouse Fresnel lens opens"
          bc.auto_generated.should be_true
        end

      end

      context "when the page has a differently capitalized DeScriPtioN meta tag" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23-caps.htm'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should still find it and use it" do
          surl = superfresh_urls(:with_description_meta)
          SuperfreshUrlToBoostedContent.perform(surl.url, @aff.id)
          bc = @aff.boosted_contents.find_by_url(surl.url)
          bc.description.should == "New display building for the original Fire Island Lighthouse Fresnel lens opens"
        end
      end

      context "when the page does not have a description meta tag" do
        before do
          doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/data-layers.html'))
          Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
        end

        it "should use the initial subset of non-HTML words of the web page as the description" do
          surl = superfresh_urls(:without_description_meta)
          SuperfreshUrlToBoostedContent.perform(surl.url, @aff.id)
          bc = @aff.boosted_contents.find_by_url(surl.url)
          bc.title.should == "Carribean Sea Regional Atlas - Map Service and Layer..."
          bc.description.should == "Carribean Sea Regional Atlas. -. Map Service and Layer Descriptions. Ocean Exploration and Research (OER) Digital Atlases. Caribbean Sea. Description. This map aids the public in locating surveys carried out by NOAA's Office of Exploration and..."
        end
      end
    end
  end

  context "when the URL points to a PDF" do
    before do
      @superfresh_url = superfresh_urls(:pdf)
      @raw_pdf = File.open(Rails.root.to_s + "/spec/fixtures/pdf/test.pdf")
      IO.stub!(:open).and_return @raw_pdf
    end

    it "should open the pdf file" do
      SuperfreshUrlToBoostedContent.perform(@superfresh_url.url, @aff.id)
    end
    
    it "should create a boosted content that has a title and description from the pdf" do
      SuperfreshUrlToBoostedContent.perform(@superfresh_url.url, @aff.id)
      boosted_content = @aff.boosted_contents.find_by_url(@superfresh_url.url)
      boosted_content.should_not be_nil
      boosted_content.title.should == "This is a pdf file"
      boosted_content.description.should == "This is a pdf file.  It’s here to test out our PDF code."
      boosted_content.url.should == @superfresh_url.url
    end
  end
  
  describe "#is_pdf?" do
    it "should return true if the URL ends in '.pdf'" do
      SuperfreshUrlToBoostedContent.is_pdf?("something.pdf").should be_true
    end
    
    it "should return false if the URL does not end in .pdf" do
      SuperfreshUrlToBoostedContent.is_pdf?('not a pdf').should be_false
    end
  end
end