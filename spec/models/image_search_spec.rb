require 'spec/spec_helper'

describe ImageSearch do
  describe "#run" do
    before do
      @search = ImageSearch.new({:query => 'shuttle'})
    end

    it "should log info about the query" do
      QueryImpression.should_receive(:log).with(:image, Affiliate::USAGOV_AFFILIATE_NAME, 'shuttle', ["IMAG"])
      @search.run
    end

  end

  subject do
    search = ImageSearch.new(:query => "White House")
    body = File.read(Rails.root.to_s + "/spec/fixtures/json/bing_image_results_for_white_house.json")
    search.stub!(:perform).and_return(body)
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
        json.should =~ /total/
        json.should =~ /startrecord/
        json.should =~ /endrecord/
      end

      context "when an error occurs" do
        before do
          @search.instance_variable_set :@error_message, "Some error"
        end

        it "should output an error if an error is detected" do
          json = @search.to_json
          json.should =~ /"error":"Some error"/
        end
      end
    end
  end
end
