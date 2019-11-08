require 'spec_helper'

describe NewsItem do
  fixtures :affiliates, :rss_feed_urls, :rss_feeds, :news_items, :youtube_profiles

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
    it { is_expected.to validate_presence_of :link }
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :published_at }
    it { is_expected.to validate_presence_of :guid }
    it { is_expected.to validate_uniqueness_of(:guid).case_insensitive.scoped_to(:rss_feed_url_id) }
    it { is_expected.to validate_uniqueness_of(:link).case_insensitive.scoped_to(:rss_feed_url_id) }
    it { is_expected.to validate_presence_of :rss_feed_url_id }

    it "should create a new instance given valid attributes" do
      NewsItem.create!(@valid_attributes)
    end

    it 'should allow blank description for YouTube video' do
      NewsItem.create!(@valid_attributes.merge(:link => 'HTTPs://www.youtube.com/watch?v=q3GjT4zvUkk',
                                               :description => nil))
    end

    it 'allows blank description when body is present' do
      NewsItem.create!(@valid_attributes.merge(body: 'content body',
                                               description: '   '))
    end

    it "should scrub out extra whitespace, tabs, newlines from fields" do
      news_item = NewsItem.create!(
        @valid_attributes.merge(title: " \nDOD \tMarks Growth\r in Spouses’ \u00a0 Employment Program \n     ",
                                description: " \nSome     description \n     ",
                                link: "\t\t\t\n http://www.foo.gov/1.html\t\n",
                                guid: "\t\t\t\nhttp://www.foo.gov/1.html \t\n",
        ))
      expect(news_item.title).to eq('DOD Marks Growth in Spouses’ Employment Program')
      expect(news_item.description).to eq('Some description')
      expect(news_item.link).to eq('http://www.foo.gov/1.html')
      expect(news_item.guid).to eq('http://www.foo.gov/1.html')
    end

    it 'should set tags to image if media_thumbnail_url and media_content_url are present' do
      properties = {
        media_thumbnail: {
          url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_s.jpg', height: '75', width: '75' },
        media_content: {
          url: 'http://farm9.staticflickr.com/8381/8594929349_f6d8163c36_b.jpg', type: 'image/jpeg', height: '819', width: '1024' }
      }
      news_item = NewsItem.create!(@valid_attributes.merge properties: properties)
      expect(NewsItem.find(news_item.id).tags).to eq(%w(image))
    end

    it 'should validate link URL is a well-formed absolute URL' do
      news_item = NewsItem.new(@valid_attributes.merge(link: '/relative/url'))
      expect(news_item.valid?).to be false
    end

    it 'requires unique urls, regardless of protocol' do
      NewsItem.create!(@valid_attributes.merge(link: 'http://foo.com'))
      news_item = NewsItem.new(@valid_attributes.merge(link: 'https://foo.com', guid: 'some other guid'))
      expect(news_item.valid?).to be false
      expect(news_item.errors[:link]).to include('has already been taken')
    end
  end

  describe "#language" do
    let(:news_item) { NewsItem.new(@valid_attributes) }

    context 'when RSS feed URL does not have language specified' do
      context 'when owner is an Affiliate' do
        it 'should use locale of first affiliate associated with feed URL' do
          expect(news_item.language).to eq('en')
        end
      end

      context 'when owner is a YoutubeProfile' do
        before do
          news_item.update_attribute(:rss_feed_url_id, rss_feed_urls(:whitehouse_youtube_url).id)
        end

        it 'should use locale of first affiliate associated with feed URL youtube profile' do
          expect(news_item.language).to eq('en')
        end
      end
    end

    context 'when RSS feed URL has language specified' do
      before do
        news_item.rss_feed_url.language = 'es'
      end

      it 'should use it' do
        expect(news_item.language).to eq('es')
      end
    end

    context 'when parent RSS feed URL is not associated with any RSS feeds' do
      before do
        news_item.rss_feed_url.rss_feeds.delete_all
      end

      it 'should default to English' do
        expect(news_item.language).to eq('en')
      end
    end
  end

  describe '#fast_delete' do
    it 'delete from mysql and elasticsearch' do
      ids = [news_items(:item1).id, news_items(:item2).id].freeze
      expect(ElasticNewsItem).to receive(:delete).with(ids)
      NewsItem.fast_delete(ids)
      expect(NewsItem.where(id: ids)).to be_empty
    end
  end

  describe '#duration=' do
    it 'sets duration' do
      news_item = NewsItem.create!(@valid_attributes)
      news_item.duration = '1:00'
      news_item.save!
      expect(NewsItem.find(news_item.id).duration).to eq('1:00')
    end
  end
end
