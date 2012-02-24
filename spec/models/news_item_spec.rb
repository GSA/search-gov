require 'spec/spec_helper'

describe NewsItem do
  fixtures :rss_feeds, :news_items
  before do
    @valid_attributes = {
      :link => 'http://www.whitehouse.gov/latest_story.html',
      :title => "Big story here",
      :description => "Corps volunteers have promoted blah blah blah.",
      :published_at => DateTime.parse("2011-09-26 21:33:05"),
      :guid => '80798 at www.whitehouse.gov',
      :rss_feed_id => rss_feeds(:white_house_blog).id
    }
  end

  it { should validate_presence_of :link }
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :published_at }
  it { should validate_presence_of :guid }
  it { should validate_uniqueness_of(:guid).scoped_to(:rss_feed_id) }
  it { should validate_presence_of :rss_feed_id }
  it { should belong_to :rss_feed }

  it "should create a new instance given valid attributes" do
    NewsItem.create!(@valid_attributes)
  end

  describe "#search_for(query, rss_feeds, since)" do
    before do
      NewsItem.delete_all
      @blog = rss_feeds(:white_house_blog)
      @gallery = rss_feeds(:white_house_press_gallery)
      @blog_item = NewsItem.create!(:rss_feed_id => @blog.id, :guid => "unique to feed", :published_at => 3.days.ago,
                                    :link => "http://www.wh.gov/ns1",
                                    :title => "Obama adopts policies similar to other policies",
                                    :description => "<p> Ed note: This&nbsp;has been cross-posted&nbsp;from the Office of Science and Technology policy&#39;s <a href='http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime'><img alt='ignore' src='/foo.jpg' />blog</a></p> <p> Today is a good day for policy science and technology, a good day for scientists and engineers, and a good day for the nation and policies.</p>")
      @gallery_item = NewsItem.create!(:rss_feed_id => @gallery.id, :guid => "unique to feed", :published_at => 1.day.ago,
                                       :link => "http://www.wh.gov/ns2", :title => "Obama adopts some more things",
                                       :description => "<p>that is the policy.</p>")
      NewsItem.reindex
      Sunspot.commit
    end

    it "should restrict results to the collection of RSS feeds specified" do
      search = NewsItem.search_for("policy", [@blog])
      search.total.should == 1
      search.results.first.should == @blog_item
    end

    it "should sort by descreasing published_at" do
      search = NewsItem.search_for("policy", [@blog, @gallery])
      search.total.should == 2
      search.results.first.should == @gallery_item
    end

    it "should instrument the call to Solr with the proper action.service namespace and query param hash" do
      ActiveSupport::Notifications.should_receive(:instrument).
        with("solr_search.usasearch", hash_including(:query => hash_including(:rss_feeds => @blog.name, :model=>"NewsItem", :term => "policy")))
      NewsItem.search_for("policy", [@blog])
    end

    context "when the 'since' parameter is specified" do
      let(:since) { 2.days.ago }

      it "should restrict results by when news was published" do
        search = NewsItem.search_for("policy", [@blog, @gallery], since)
        search.total.should == 1
        search.results.first.should == @gallery_item
      end

      it "should instrument the call to Solr with the proper action.service namespace and query param hash" do
        ActiveSupport::Notifications.should_receive(:instrument).
          with("solr_search.usasearch", hash_including(:query => hash_including(:since => since, :rss_feeds => "#{@blog.name},#{@gallery.name}", :model=>"NewsItem", :term => "policy")))
        NewsItem.search_for("policy", [@blog, @gallery], since)
      end
    end

    context "when query contains special characters" do
      ['"   ', '   "       ', '+++', '+-', '-+'].each do |query|
        specify { NewsItem.search_for(query, [@blog, @gallery]).should be_nil }
      end

      %w(+++science --science -+science).each do |query|
        specify { NewsItem.search_for(query, [@blog, @gallery]).total.should == 1 }
      end
    end
  end
end