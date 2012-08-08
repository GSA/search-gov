require 'spec/spec_helper'

describe NewsItem do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls, :news_items
  before do
    @valid_attributes = {
      :link => 'http://www.whitehouse.gov/latest_story.html',
      :title => "Big story here",
      :description => "Corps volunteers have promoted blah blah blah.",
      :published_at => DateTime.parse("2011-09-26 21:33:05"),
      :guid => '80798 at www.whitehouse.gov',
      :rss_feed_id => rss_feeds(:white_house_blog).id,
      :rss_feed_url_id => rss_feed_urls(:white_house_blog_url).id,
      :contributor => "President",
      :publisher => "Briefing Room",
      :subject => "Economy"
    }
  end

  describe "creating a new NewsItem" do
    it { should validate_presence_of :link }
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :published_at }
    it { should validate_presence_of :guid }
    it { should validate_uniqueness_of(:guid).scoped_to(:rss_feed_id) }
    it { should validate_uniqueness_of(:link).scoped_to(:rss_feed_id) }
    it { should validate_presence_of :rss_feed_id }
    it { should validate_presence_of :rss_feed_url_id }
    it { should belong_to :rss_feed }

    it "should create a new instance given valid attributes" do
      NewsItem.create!(@valid_attributes)
    end

    it 'should allow blank description for YouTube video' do
      NewsItem.create!(@valid_attributes.merge(:link => 'HTTP://www.youtube.com/watch?v=q3GjT4zvUkk',
                                               :description => nil))
    end

    it "should scrub out extra whitespace, tabs, newlines from title/desc" do
      news_item = NewsItem.create!(@valid_attributes.merge(:title => " \nDOD \tMarks Growth\r in Spouses’ Employment Program \n     ", :description => " \nSome     description \n     "))
      news_item.title.should == 'DOD Marks Growth in Spouses’ Employment Program'
      news_item.description.should == 'Some description'
    end
  end

  describe "#search_for(query, rss_feeds, since = nil, page = 1, contributor, subject, publisher)" do
    before do
      NewsItem.delete_all
      @blog = rss_feeds(:white_house_blog)
      @gallery = rss_feeds(:white_house_press_gallery)
      @blog_item = NewsItem.create!(:rss_feed_url_id => rss_feed_urls(:white_house_blog_url).id, :rss_feed_id => @blog.id, :guid => "unique to feed", :published_at => 3.days.ago,
                                    :link => "http://www.wh.gov/ns1",
                                    :title => "Obama adopts policies similar to other policies",
                                    :description => "<p> Ed note: This&nbsp;has been cross-posted&nbsp;from the Office of Science and Technology policy&#39;s <a href='http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime'><img alt='ignore' src='/foo.jpg' />blog</a></p> <p> Today is a good day for policy science and technology, a good day for scientists and engineers, and a good day for the nation and policies.</p>",
                                    :contributor => "President",
                                    :publisher => "Briefing Room",
                                    :subject => "Economy")

      @gallery_item = NewsItem.create!(:rss_feed_url_id => rss_feed_urls(:white_house_press_gallery_url).id, :rss_feed_id => @gallery.id, :guid => "unique to feed", :published_at => 1.day.ago,
                                       :link => "http://www.wh.gov/ns2", :title => "Obama adopts some more things",
                                       :description => "<p>that is the policy.</p>",
                                       :contributor => "President",
                                       :publisher => "Briefing Room",
                                       :subject => "HIV")
      NewsItem.reindex
      Sunspot.commit
    end

    it "should restrict results to the collection of RSS feeds specified" do
      search = NewsItem.search_for("policy", [@blog])
      search.total.should == 1
      search.results.first.should == @blog_item
    end

    context "when DublinCore fields are passed in" do
      it "should facet and restrict results based on those criteria" do
        search = NewsItem.search_for("policy", [@blog], nil, nil, nil, 'President', 'Economy', 'Briefing Room')
        search.total.should == 1
        search.results.first.should == @blog_item
      end
    end

    context "when there are no RSS feeds passed in" do
      before do
        @affiliate = @blog.affiliate
        @affiliate.rss_feeds.each { |f| f.update_attribute(:shown_in_govbox, false) }
      end

      it "should return nil" do
        NewsItem.search_for("policy", @affiliate.rss_feeds.govbox_enabled).should be_nil
      end
    end

    context "when the affiliate has excluded URLs defined" do
      before do
        @blog.affiliate.excluded_urls.create!(:url => "http://www.wh.gov/ns1")
      end

      it "should exclude those from the results" do
        search = NewsItem.search_for("policy", [@blog, @gallery])
        search.total.should == 1
        search.results.first.should == @gallery_item
      end
    end

    it "should sort by descreasing published_at" do
      search = NewsItem.search_for("policy", [@blog, @gallery])
      search.total.should == 2
      search.results.first.should == @gallery_item
    end

    it "should instrument the call to Solr with the proper action.service namespace and query param hash" do
      ActiveSupport::Notifications.should_receive(:instrument).
        with("solr_search.usasearch", hash_including(:query => hash_including(:rss_feeds => @blog.name, :model => "NewsItem", :term => "policy")))
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
          with("solr_search.usasearch", hash_including(:query => hash_including(:since => since, :rss_feeds => "#{@blog.name},#{@gallery.name}", :model => "NewsItem", :term => "policy")))
        NewsItem.search_for("policy", [@blog, @gallery], since)
      end
    end

    context "when query contains only special characters" do
      ['"   ', '   "       ', '+++', '+-', '-+'].each do |query|
        specify { NewsItem.search_for(query, [@blog, @gallery]).total.should == 2 }
      end

      %w(+++science --science -+science).each do |query|
        specify { NewsItem.search_for(query, [@blog, @gallery]).total.should == 1 }
      end
    end

    context "when query is blank" do
      it "should return with all items" do
        NewsItem.search_for('', [@blog, @gallery]).total.should == 2
      end
    end
  end
end