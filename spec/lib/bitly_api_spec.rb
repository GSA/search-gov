require 'spec/spec_helper'

describe BitlyAPI do
  describe "#new" do
    it "should set the username, password and API key if passed" do
      bitly_api = BitlyAPI.new(:username => "usagov", :password => "password", :api_key => "apikey")
      bitly_api.username.should == "usagov"
      bitly_api.password.should == "password"
      bitly_api.api_key.should == "apikey"
    end
  end

  describe "#grab_csv_for_date" do
    context "when signed in" do
      before do
        @csv = File.read(Rails.root.to_s + "/spec/fixtures/csv/bitly_popular_urls.csv")
        @bitly_api = BitlyAPI.new(:username => "usagov", :password => "password", :api_key => "apikey")
        File.stub!(:open).and_return true
        @browser = Mechanize.new
        @browser.stub!(:get).and_return @csv
        Mechanize.stub!(:new).and_return @browser
        @bitly_api.stub!(:signed_in?).and_return true
        @bitly_api.stub!(:sign_in).and_return true
      end

      it "should check to see if the file exist, and if so delete it" do
        date = Date.yesterday
        File.should_receive(:exist?).with("allday-#{date.strftime("%Y%m%d-%H%M")}.csv").and_return true
        File.should_receive(:delete).with("allday-#{date.strftime("%Y%m%d-%H%M")}.csv").and_return true
        @bitly_api.grab_csv_for_date
      end

      it "should default to yesterday" do
        date = Date.yesterday
        @bitly_api.grab_csv_for_date.should =~ /allday-#{date.strftime("%Y%m%d-%H%M")}.csv/
      end

      it "should use a date if provided" do
        date = Date.parse('2011-07-01')
        @bitly_api.grab_csv_for_date(date).should =~ /allday-20110701-0000.csv/
      end
    end
  end

  describe "#parse_csv" do
    before do
      @csv_file_name = Rails.root.to_s + "/spec/fixtures/csv/bitly_popular_urls.csv"
      @bitly_api = BitlyAPI.new(:username => "usagov", :password => "***REMOVED***", :api_key => 'R_8e9e6b912573a6c8b7bd013f1f4f68e6')
      @bitly_api.stub!(:sign_in).and_return true
      RestClient.stub!(:get).and_return '{"status_code": 200, "data": {"info": [{"hash": "oOIxOJ", "title": "NASA - \nMonitoring the Launch Countdown", "created_at": 1311596970, "created_by": "bitly", "global_hash": "oOIxOJ", "user_hash": "oOIxOJ"}], "expand": [ { "hash": "oOIxOJ", "long_url": "http:\/\/www.nasa.gov\/multimedia\/imagegallery\/image_feature_2018.html", "user_hash": "oOIxOJ", "global_hash": "oOIxOJ" } ]}, "status_txt": "OK"}'
      @bitly_api.bitly_map = {}
    end

    it "should set the bitly_map value" do
      @bitly_api.parse_csv(@csv_file_name)
      @bitly_api.bitly_map.should_not be_nil
    end
  end

  describe "#get_popular_links_for_domain" do
    before do
      @bitly_api = BitlyAPI.new(:username => "usagov", :password => "password", :api_key => "apikey")
      @bitly_map = {}
      @bitly_map["12345"] = { :long_url => "http://search.usa.gov", :title => "Search.USA.gov", :clicks => 100 }
      @bitly_map["23456"] = { :long_url => "http://irs.gov/index.html", :title => "IRS home page", :clicks => 100 }
      @bitly_api.bitly_map = @bitly_map
    end

    it "should return links that match the domain specified" do
      links = @bitly_api.get_popular_links_for_domain("usa.gov")
      links.size.should == 1
      links.first[:long_url] = "http://search.usa.gov"
    end
  end

=begin
  describe "#sign_in" do
    before do
      @bitly_api = BitlyAPI.new(:username => "usagov", :password => "password", :api_key => "apikey")
    end

    it "should sign in" do
      @bitly_api.sign_in
      @bitly_api.signed_in?.should == true
    end
  end
=end

  describe "CSVFileReader" do
    it "should set the body to csv_body" do
      csv_file_saver = CSVFileSaver.new(nil, {'content-type' => 'text/html'}, "the body")
      csv_file_saver.csv_body.should == "the body"
    end
  end
end