require 'spec_helper'

describe SuperfreshUrl do
  fixtures :affiliates

  before do
    @valid_attributes = {:url => "http://search.usa.gov/recently-updated-url", :affiliate => affiliates(:basic_affiliate)}
  end

  describe "Creating new instance" do
    it { should belong_to :affiliate }
    it { should validate_presence_of :url }
    it { should allow_value("http://some.site.gov/url").for(:url) }
    it { should allow_value("http://some.site.mil/url").for(:url) }
    it { should allow_value("http://some.govsite.com/url").for(:url) }
    it { should allow_value("http://some.govsite.us/url").for(:url) }
    it { should allow_value("http://some.govsite.info/url").for(:url) }
    it { should allow_value("https://some.govsite.info/url").for(:url) }
  end

  describe "#process_file" do
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

      it "should create a new SuperfreshUrl for each of the lines in the file" do
        SuperfreshUrl.process_file(@file)
        @urls.each {|url| SuperfreshUrl.find_by_url_and_affiliate_id(url, nil).should_not be_nil}
      end

      it "should use an affiliate if specified" do
        affiliate = affiliates(:basic_affiliate)
        SuperfreshUrl.process_file(@file, affiliate)
        @urls.each {|url| SuperfreshUrl.find_by_url_and_affiliate_id(url, affiliate).should_not be_nil}
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
        lambda { SuperfreshUrl.process_file(@file) }.should raise_error('Too many URLs in your file.  Please limit your file to 100 URLs.')
      end

      context "when a max number of URLs is passed that is greater than the default max" do
        it "should allow all of the urls" do
          lambda { SuperfreshUrl.process_file(@file, nil, 1000)}.should_not raise_error('Too many URLs in your file.  Please limit your file to 100 URLs.')
        end
      end
    end
  end
end
