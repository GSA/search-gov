require 'spec_helper'

describe SuperfreshUrl do
  fixtures :affiliates

  before do
    @valid_attributes = {:url => "http://search.usa.gov/recently-updated-url"}
  end

  describe "Creating new instance" do
    it { should belong_to :affiliate }
    it { should validate_presence_of :url }
    it { should allow_value("http://some.site.gov/url").for(:url) }
    it { should allow_value("http://some.site.mil/url").for(:url) }
    it { should allow_value("http://some.govsite.com/url").for(:url) }
    it { should allow_value("http://some.govsite.us/url").for(:url) }
    it { should allow_value("http://some.govsite.info/url").for(:url) }
  end

  describe "#uncrawled_urls" do
    before do
      SuperfreshUrl.delete_all
      @first_uncrawled_url = SuperfreshUrl.create(:url => 'http://some.mil/')
      @affiliate_uncrawled_url = SuperfreshUrl.create(:url => 'http://affiliate.uncrawled.mil', :affiliate => affiliates(:basic_affiliate))
      @last_uncrawled_url = SuperfreshUrl.create(:url => 'http://another.mil')
      @already_crawled_url = SuperfreshUrl.create(:url => 'http://already.crawled.mil', :crawled_at => Time.now)
    end

    context "when looking up uncrawled URLs without an affiliate" do
      it "should limit the number of URLs returned if specified" do
        SuperfreshUrl.should_receive(:find_all_by_crawled_at).with(nil, {:limit => 500, :order => 'id asc'}).and_return []
        SuperfreshUrl.uncrawled_urls(500)
      end

      it "should not limit the number of URLs returned if the value is not specified" do
        SuperfreshUrl.should_receive(:find_all_by_crawled_at).with(nil, {:order => 'id asc'}).and_return []
        SuperfreshUrl.uncrawled_urls
      end

      it "should return all the uncrawled urls (i.e. where crawled_at == nil), including those for affiliates, ordered by created time ascending" do
        uncrawled_urls = SuperfreshUrl.uncrawled_urls
        uncrawled_urls.size.should == 3
        uncrawled_urls.first.should == @first_uncrawled_url
        uncrawled_urls.last.should == @last_uncrawled_url
        uncrawled_urls.include?(@already_crawled_url).should be_false
      end
    end

    context "when looking up crawled URLs with an affiliate" do
      it "should limit the number of URLs returned if specified" do
        SuperfreshUrl.should_receive(:find_all_by_crawled_at_and_affiliate_id).with(nil, affiliates(:basic_affiliate).id, {:order => 'id asc', :limit => 500}).and_return []
        SuperfreshUrl.uncrawled_urls(500, affiliates(:basic_affiliate))
      end

      it "should return the uncrawled URLs for that affiliate" do
        uncrawled_urls = SuperfreshUrl.uncrawled_urls(nil, affiliates(:basic_affiliate))
        uncrawled_urls.size.should == 1
        uncrawled_urls.include?(@affiliate_uncrawled_url).should be_true
        uncrawled_urls.include?(@first_uncrawled_url).should be_false
      end
    end
  end

  describe "#crawled_urls" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @first_crawled_url = SuperfreshUrl.create(:url => 'http://crawled.mil', :crawled_at => Time.now, :affiliate => @affiliate)
      @last_crawled_url = SuperfreshUrl.create(:url => 'http://another.crawled.mil', :crawled_at => Time.now, :affiliate => @affiliate)
    end

    it "should return the first page of all crawled urls" do
      crawled_urls = SuperfreshUrl.crawled_urls(@affiliate)
      crawled_urls.size.should == 2
    end

    it "should paginate the results if the page is passed in" do
      crawled_urls = SuperfreshUrl.crawled_urls(@affiliate, 2)
      crawled_urls.should be_empty
    end

    it "should return nil if the affiliate is missing" do
      SuperfreshUrl.crawled_urls.should == nil
    end
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
