# coding: utf-8
require 'spec_helper'

describe NewsItem do
  fixtures :affiliates, :rss_feed_urls, :rss_feeds, :news_items

  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    @valid_attributes = {
      :link => 'http://www.whitehouse.gov/latest_story.html',
      :title => "Big story here",
      :description => "Corps volunteers have promoted blah blah blah.",
      :published_at => DateTime.parse("2011-09-26 21:33:05"),
      :guid => '80798 at www.whitehouse.gov',
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
    it { should validate_uniqueness_of(:guid).scoped_to(:rss_feed_url_id).case_insensitive }
    it { should validate_uniqueness_of(:link).scoped_to(:rss_feed_url_id).case_insensitive }
    it { should validate_presence_of :rss_feed_url_id }

    it "should create a new instance given valid attributes" do
      NewsItem.create!(@valid_attributes)
    end

    it 'should allow blank description for YouTube video' do
      NewsItem.create!(@valid_attributes.merge(:link => 'HTTP://www.youtube.com/watch?v=q3GjT4zvUkk',
                                               :description => nil))
    end

    it "should scrub out extra whitespace, tabs, newlines from title/desc" do
      news_item = NewsItem.create!(
          @valid_attributes.merge(title: " \nDOD \tMarks Growth\r in Spouses’ Employment Program \n     ",
                                  description: " \nSome     description \n     "))
      news_item.title.should == 'DOD Marks Growth in Spouses’ Employment Program'
      news_item.description.should == 'Some description'
    end

    it 'should set tags to image if media_thumbnail_url and media_content_url are present' do
      properties = {
          media_thumbnail: {
              url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_s.jpg',
              height: '75', width: '75' },
          media_content: {
              url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_b.jpg',
              type: 'image/jpeg',
              height: '819', width: '1024' }
      }
      news_item = NewsItem.create!(@valid_attributes.merge properties: properties)
      NewsItem.find(news_item.id).tags.should == %w(image)
    end
  end

  describe "#search_for(query, rss_feeds, options = {})" do
    before do
      NewsItem.delete_all
      @blog = rss_feeds(:white_house_blog)
      @gallery = rss_feeds(:white_house_press_gallery)
      @blog_item = NewsItem.create!(rss_feed_url_id: rss_feed_urls(:white_house_blog_url).id,
                                    guid: 'unique to feed',
                                    published_at: 3.days.ago,
                                    link: 'http://www.wh.gov/ns1',
                                    title: 'Obama adopts policies similar to other policies',
                                    description: "<p> Ed note: This&nbsp;has been cross-posted&nbsp;from the Office of Science and Technology policy&#39;s <a href='http://www.whitehouse.gov/blog/2011/09/26/supporting-scientists-lab-bench-and-bedtime'><img alt='ignore' src='/foo.jpg' />blog</a></p> <p> Today is a good day for policy science and technology, a good day for scientists and engineers, and a good day for the nation and policies.</p>",
                                    contributor: 'President',
                                    publisher: 'Briefing Room',
                                    subject: 'Economy')

      properties = {
          media_thumbnail: {
              url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_s.jpg',
              height: '75', width: '75' },
          media_content: {
              url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_b.jpg',
              type: 'image/jpeg',
              height: '819', width: '1024' }
      }
      @gallery_item = NewsItem.create!(rss_feed_url: rss_feed_urls(:white_house_press_gallery_url),
                                       guid: '`unique to feed',
                                       published_at: 1.day.ago,
                                       link: 'http://www.wh.gov/ns2',
                                       title: 'Obama adopts some more things',
                                       description: '<p>that is the policy.</p>',
                                       contributor: 'President',
                                       publisher: 'Briefing Room',
                                       subject: 'HIV',
                                       properties: properties)
      NewsItem.reindex
      Sunspot.commit
    end

    it "should restrict results to the collection of RSS feeds specified" do
      search = NewsItem.search_for('policy', [@blog], affiliate)
      search.total.should == 1
      search.results.first.should == @blog_item
    end

    context "when DublinCore fields are passed in" do
      it "should facet and restrict results based on those criteria" do
        search = NewsItem.search_for('policy', [@blog], affiliate,
                                     contributor: 'President',
                                     subject: 'Economy',
                                     publisher: 'Briefing Room')
        search.total.should == 1
        search.results.first.should == @blog_item
      end
    end

    describe "sorting" do
      context "when sort_by_relevance param is true" do
        it 'should sort results by relevance' do
          search = NewsItem.search_for('policy', [@blog, @gallery], affiliate,
                                       sort_by_relevance: true)
          search.results.first.should == @blog_item
        end
      end

      context "when sort_by_relevance param is false" do
        it 'should sort results by date' do
          search = NewsItem.search_for('policy', [@blog, @gallery], affiliate,
                                       sort_by_relevance: false)
          search.results.first.should == @gallery_item
        end
      end
    end

    context "when searching with blank rss feeds" do
      specify { NewsItem.search_for('policy', [], affiliate).should be_nil }
    end

    context "when the affiliate has excluded URLs defined" do
      before do
        affiliate.excluded_urls.create!(url: 'http://www.wh.gov/ns1')
      end

      it "should exclude those from the results" do
        search = NewsItem.search_for("policy", [@blog, @gallery], affiliate)
        search.total.should == 1
        search.results.first.should == @gallery_item
      end
    end

    it "should sort by descreasing published_at" do
      search = NewsItem.search_for("policy", [@blog, @gallery], affiliate)
      search.total.should == 2
      search.results.first.should == @gallery_item
    end

    it "should instrument the call to Solr with the proper action.service namespace and query param hash" do
      ActiveSupport::Notifications.should_receive(:instrument).
        with("solr_search.usasearch", hash_including(:query => hash_including(:rss_feeds => @blog.name, :model => "NewsItem", :term => "policy")))
      NewsItem.search_for('policy', [@blog], affiliate)
    end

    context "when the 'since' parameter is specified" do
      let(:since) { 2.days.ago.freeze }

      it "should restrict results by when news was published" do
        search = NewsItem.search_for("policy", [@blog, @gallery], affiliate, since: since)
        search.total.should == 1
        search.results.first.should == @gallery_item
      end

      it "should instrument the call to Solr with the proper action.service namespace and query param hash" do
        ActiveSupport::Notifications.should_receive(:instrument).
          with("solr_search.usasearch", hash_including(:query => hash_including(:since => since, :rss_feeds => "#{@blog.name},#{@gallery.name}", :model => "NewsItem", :term => "policy")))
        NewsItem.search_for("policy", [@blog, @gallery], affiliate, since: since)
      end
    end

    context "when the 'until' parameter is specified" do
      let(:until_ts) { 2.days.ago.end_of_day.freeze }

      it 'should restrict results by when news was published' do
        search = NewsItem.search_for("policy", [@blog, @gallery], affiliate, until: until_ts)
        search.total.should == 1
        search.results.first.should == @blog_item
      end

      it "should instrument the call to Solr with the proper action.service namespace and query param hash" do
        ActiveSupport::Notifications.should_receive(:instrument).
          with("solr_search.usasearch", hash_including(:query => hash_including(until: until_ts, rss_feeds: "#{@blog.name},#{@gallery.name}", model: 'NewsItem', term: 'policy')))
        NewsItem.search_for("policy", [@blog, @gallery], affiliate, until: until_ts)
      end
    end

    context "when the 'since' and 'until' parameters are specified" do
      let(:since_ts) { 1.week.ago.end_of_day.freeze }
      let(:until_ts) { 2.days.ago.end_of_day.freeze }

      it 'should restrict results by when news was published' do
        search = NewsItem.search_for('policy', [@blog, @gallery], affiliate,
                                     since: since_ts, until: until_ts)
        search.total.should == 1
        search.results.first.should == @blog_item

        NewsItem.search_for('policy', [@blog, @gallery], affiliate,
                            since: 1.month.ago, until: 1.week.ago).total.should == 0
      end

      it "should instrument the call to Solr with the proper action.service namespace and query param hash" do
        ActiveSupport::Notifications.should_receive(:instrument).
            with('solr_search.usasearch',
                 { query: { since: since_ts,
                            until: until_ts,
                            rss_feeds: "#{@blog.name},#{@gallery.name}",
                            model: 'NewsItem',
                            term: 'policy' } })
        NewsItem.search_for('policy', [@blog, @gallery], affiliate,
                            since: since_ts, until: until_ts)
      end
    end

    context 'when tags parameter is specified' do
      it 'should restrict results with media content and thumbnail in the properties' do
        search = NewsItem.search_for('policy', [@blog, @gallery], affiliate, tags: %w(image))
        search.total.should == 1
        search.results.first.should == @gallery_item
      end
    end

    context "when query contains only special characters" do
      ['"   ', '   "       ', '+++', '+-', '-+'].each do |query|
        specify { NewsItem.search_for(query, [@blog, @gallery], affiliate).total.should == 2 }
      end

      %w(+++science --science -+science).each do |query|
        specify { NewsItem.search_for(query, [@blog, @gallery], affiliate).total.should == 1 }
      end
    end

    context "when query is blank" do
      it "should return with all items" do
        NewsItem.search_for('', [@blog, @gallery], affiliate).total.should == 2
      end
    end

    context 'when options is an empty Hash' do
      it "should return with all items" do
        NewsItem.search_for('', [@blog, @gallery], affiliate, {}).total.should == 2
      end
    end

    context 'when .search raises an error' do
      it 'should return nil' do
        NewsItem.should_receive(:search).and_raise(RSolr::Error::Http.new({}, {}))
        NewsItem.search_for('', [@blog], affiliate).should be_nil
      end
    end
  end

  describe ".title_description_date_hash_by_link(affiliate, urls)" do
    before do
      attributes = {
        :link => 'http://www.whitehouse.gov/latest_story.html',
        :title => "Big story here",
        :description => "Corps volunteers have promoted blah blah blah.",
        :published_at => DateTime.parse("2011-09-26 21:33:05"),
        :guid => 'some guid',
        :rss_feed_url_id => rss_feed_urls(:white_house_blog_url).id,
        :contributor => "President",
        :publisher => "Briefing Room",
        :subject => "Economy"
      }
      2.times do |x|
        NewsItem.create!(attributes.merge(:link => attributes[:link]+x.to_s, :guid => attributes[:guid]+x.to_s,
                                          :title => attributes[:title]+x.to_s))
      end
      NewsItem.create!(attributes.merge(:link => attributes[:link]+"1", :guid => attributes[:guid]+"other",
                                        :title => 'ignore from another affiliate',
                                        :rss_feed_url_id => rss_feed_urls(:another_url).id))
    end

    it "should return :link, :title, :description, :published_at for news items belonging to that affiliate with matching urls" do
      urls = %w{http://www.whitehouse.gov/latest_story.html0 http://www.whitehouse.gov/latest_story.html1}
      result = NewsItem.title_description_date_hash_by_link(affiliate, urls)
      result.size.should == 2
      result['http://www.whitehouse.gov/latest_story.html0'].should be_present
      result['http://www.whitehouse.gov/latest_story.html1'].should be_present
      result['http://www.whitehouse.gov/latest_story.html1'].title.should == "Big story here1"
    end
  end
end
