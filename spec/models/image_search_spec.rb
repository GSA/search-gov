require "#{File.dirname(__FILE__)}/../spec_helper"

describe ImageSearch do
  before do
    # Image search for "White House"
    uri = "http://api.bing.net/json.aspx?image.offset=0&image.count=10&AppId=A4C32FAE6F3DB386FC32ED1C4F3024742ED30906&sources=Spell+Image+RelatedSearch&Options=EnableHighlighting&query=White%20House%20(scopeid:usagovall%20OR%20site:.gov%20OR%20site:.mil)"
    @body = File.read(RAILS_ROOT + "/spec/fixtures/json/bing_image_results_for_white_house.json")
  end

  subject do
    search = ImageSearch.new(:query => "White House")
    search.stub!(:perform).and_return(@body)
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
  end

  describe "#as_json" do
    context "when converting search response to json" do
      before do
        @search = subject
        allow_message_expectations_on_nil
      end

      it "should generate a JSON representation of total, start and end records, spelling suggestions, related searches and search results" do
        json = @search.to_json
        json.should contain(/total/)
        json.should contain(/startrecord/)
        json.should contain(/endrecord/)
      end

      context "when an error occurs" do
        before do
          @search.error_message = "Some error"
        end

        it "should output an error if an error is detected" do
          json = @search.to_json
          json.should contain(/"error":"Some error"/)
        end
      end
    end
  end
end
