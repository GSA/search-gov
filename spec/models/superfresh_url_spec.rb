require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SuperfreshUrl do
  fixtures :affiliates

  before do
    @valid_attributes = {
      :url => "http://search.usa.gov/recently-updated-url"
    }
  end
  
  should_validate_presence_of :url
  
  describe "#uncrawled_urls" do
    before do
      @first_uncrawled_url = SuperfreshUrl.create(:url => 'http://some.url/')
      @affiliate_uncrawled_url = SuperfreshUrl.create(:url => 'http://affiliate.uncrawled.url', :affiliate => affiliates(:basic_affiliate))
      @last_uncrawled_url = SuperfreshUrl.create(:url => 'http://another.url')
      @already_crawled_url = SuperfreshUrl.create(:url => 'http://already.crawled.url', :crawled_at => Time.now)
    end
    
    context "when looking up uncrawled URLs without an affiliate" do
      it "should return all the uncrawled urls (i.e. where crawled_at == nil), including those for affiliates, ordered by created time ascending" do
        uncrawled_urls = SuperfreshUrl.uncrawled_urls
        uncrawled_urls.size.should == 3
        uncrawled_urls.first.should == @first_uncrawled_url
        uncrawled_urls.last.should == @last_uncrawled_url
        uncrawled_urls.include?(@already_crawled_url).should be_false
      end
    end
    
    context "when looking up crawled URLs with an affiliate" do
      it "should return the uncrawled URLs for that affiliate" do
        uncrawled_urls = SuperfreshUrl.uncrawled_urls(affiliates(:basic_affiliate))
        uncrawled_urls.size.should == 1
        uncrawled_urls.include?(@affiliate_uncrawled_url).should be_true
        uncrawled_urls.include?(@first_uncrawled_url).should be_false
      end
    end
  end
  
  describe "#crawled_urls" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @first_crawled_url = SuperfreshUrl.create(:url => 'http://crawled.url', :crawled_at => Time.now, :affiliate => @affiliate)
      @last_crawled_url = SuperfreshUrl.create(:url => 'http://another.crawled.url', :crawled_at => Time.now, :affiliate => @affiliate)
    end
    
    it "should return the first page of all crawled urls" do
      crawled_urls = SuperfreshUrl.crawled_urls(@affiliate)
      crawled_urls.size.should == 2
    end
    
    it "should paginate the results if the page is passed in" do
      crawled_urls = SuperfreshUrl.crawled_urls(@affiliate, 2)
      crawled_urls.size.should == 0
    end
    
    it "should return nil if the affiliate is missing" do
      SuperfreshUrl.crawled_urls.should == nil
    end
  end       
end
