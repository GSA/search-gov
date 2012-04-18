require 'spec/spec_helper'

describe ImageSearch do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:usagov_affiliate)
  end

  describe "#run" do
    before do
      @search = ImageSearch.new(:query => 'shuttle', :affiliate => @affiliate)
    end

    it "should log info about the query" do
      QueryImpression.should_receive(:log).with(:image, @affiliate.name, 'shuttle', ["IMAG"])
      @search.run
    end

    it "should perform a bing search" do
      @search.should_not_receive(:perform_odie_search)
      @search.run
    end

    it "should handle the response as a Bing response" do
      @search.should_not_receive(:handle_odie_response)
      @search.run
    end

    context "when a Bing error occurs" do
      before do
        @search.stub!(:perform_bing_search).and_raise BingSearch::BingSearchError.new
      end

      it "should log the error" do
        Rails.logger.should_receive(:warn)
        @search.run
      end
    end
  end

  subject do
    search = ImageSearch.new(:query => "White House", :affiliate => @affiliate)
    body = File.read(Rails.root.to_s + "/spec/fixtures/json/bing_image_results_for_white_house.json")
    search.stub!(:perform_bing_search).and_return(body)
    search.run
    search
  end

  describe "#total" do
    it "is correct" do
      subject.total.should == 4340000
    end
  end

  describe "#results" do
    before do
      @result = subject.results.first
    end

    it "includes original image meta-data" do
      @result["title"].should == "White House, Washington D.C."
      @result["Url"].should == "http://biglizards.net/blog/archives/2008/08/"
      @result["DisplayUrl"].should == "http://biglizards.net/blog/archives/2008/08/"
      @result["Width"].should == 391
      @result["Height"].should == 428
      @result["FileSize"].should == 37731
      @result["ContentType"].should == "image/jpeg"
      @result["MediaUrl"].should == "http://biglizards.net/Graphics/ForegroundPix/White_House.JPG"
    end

    it "includes thumbnail meta-data" do
      @result["Thumbnail"]["Url"].should == "http://ts1.mm.bing.net/images/thumbnail.aspx?q=1581721453740&id=869b85a01b58c5a200496285e0144df1"
      @result["Thumbnail"]["FileSize"].should == 4719
      @result["Thumbnail"]["Width"].should == 146
      @result["Thumbnail"]["Height"].should == 160
      @result["Thumbnail"]["ContentType"].should == "image/jpeg"
    end

    context "when doing an affiliate Image Search" do
      context "when the affiliate specified has no results for the given query" do
        before do
          affiliate = affiliates(:non_existant_affiliate)
          @search = ImageSearch.new(:query => 'obama', :affiliate => affiliate)
        end

        it "should not attempt to backfill the results from locally-indexed documents" do
          IndexedDocument.should_not_receive(:search_for)
          @search.run
        end
      end
    end
  end

end