require 'spec_helper'

describe RssFeed do
  fixtures :affiliates, :rss_feeds, :rss_feed_urls, :navigations

  before do
    @valid_attributes = {
        owner: affiliates(:basic_affiliate),
        name: 'Blog',
        rss_feed_urls: [RssFeedUrl.new(rss_feed_owner_type: 'Affiliate',
                                       url: 'http://search.gov/rss')] }
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :owner_id }
  it { is_expected.to validate_presence_of :owner_type }
  it { is_expected.to belong_to :owner }
  it { is_expected.to have_and_belong_to_many :rss_feed_urls }
  it { is_expected.to have_many(:news_items).through :rss_feed_urls }
  it { is_expected.to have_readonly_attribute :is_managed }


  context 'on create' do
    let(:rss_feed_content) { File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml') }

    before do
      stub_request(:get, 'http://search.gov/rss').to_return( body: rss_feed_content )
    end

    it 'should create a new instance given valid attributes' do
      described_class.create!(@valid_attributes)
    end

    it 'should create navigation for owner_type Affiliate' do
      rss_feed = described_class.create!(@valid_attributes)
      expect(rss_feed.navigation).to eq(Navigation.find(rss_feed.navigation.id))
      expect(rss_feed.navigation.affiliate_id).to eq(rss_feed.owner_id)
      expect(rss_feed.navigation.position).to eq(100)
      expect(rss_feed.navigation).not_to be_is_active
    end

    context 'when is_managed is false' do
      it 'should require rss_feed_urls' do
        expect(described_class.new(@valid_attributes.except(:rss_feed_urls)).save).to be false
      end
    end

    context 'when is_managed is true' do
      it 'should not require rss_feed_urls' do
        rss_feed = described_class.new(@valid_attributes.except(:rss_feed_urls))
        rss_feed.is_managed = true
        expect(rss_feed).to be_valid
      end

      it 'should set navigation to active' do
        attributes = { owner: affiliates(:basic_affiliate),
                       name: 'Videos',
                       is_managed: true }
        rss_feed = described_class.create!(attributes)
        expect(rss_feed.navigation).to eq(Navigation.find(rss_feed.navigation.id))
        expect(rss_feed.navigation).to be_is_active
      end
    end

    context 'when the RSS feed is a valid feed' do
      it 'should validate' do
        rss_feed = described_class.new(@valid_attributes)
        expect(rss_feed.valid?).to be true
        expect(rss_feed.errors).to be_empty
      end
    end

    context 'when the URL does not point to an RSS feed' do
      let(:rss_feed_content) { File.read(Rails.root.to_s + '/spec/fixtures/html/usa_gov/site_index.html') }

      it 'should not validate' do
        rss_feed = described_class.new(@valid_attributes)
        expect(rss_feed.valid?).to be false
        expect(rss_feed.errors).not_to be_empty
      end
    end

    context 'when some error is raised in checking the RSS feed' do
      before do
        allow(DocumentFetcher).to receive(:fetch).and_raise 'Some exception'
      end

      it 'should not validate' do
        rss_feed = described_class.new(@valid_attributes)
        expect(rss_feed.valid?).to be false
        expect(rss_feed.errors).not_to be_empty
      end
    end
  end

  context 'on save' do
    it 'should not save when url in rss_feed_urls are blank' do
      blog = rss_feeds(:white_house_blog)
      blog.rss_feed_urls.build(rss_feed_owner_type: 'Affiliate', url: '')
      expect(blog.save).to be false
      expect(blog.errors.full_messages).to include('Rss feed url can\'t be blank')
    end
  end

  describe '#is_video?' do
    let(:affiliate) { affiliates(:power_affiliate) }

    context 'when each RssFeedUrl is video' do
      let(:rss_feed) do
        affiliate.rss_feeds.create!(name: 'Videos',
                                    rss_feed_urls: [rss_feed_urls(:whitehouse_youtube_url)])
      end

      specify { expect(rss_feed).to be_is_video }
    end
  end

  describe '#has_errors?' do
    let(:rss_feed) do
      affiliates(:power_affiliate).rss_feeds.create!(name: 'Got a problem',
                                                     rss_feed_urls: [rss_feed_urls(:white_house_blog_url),
                                                                     rss_feed_urls(:white_house_press_gallery_url)])
    end

    context 'when one or more RssFeedUrls is in an error state' do
      before do
        rss_feed.rss_feed_urls.first.update_attribute(:last_crawl_status, 'title is awful')
      end

      specify { expect(rss_feed.has_errors?).to be true }
    end

    context 'when no RssFeedUrl is in an error state' do
      before do
        rss_feed.rss_feed_urls.first.update_attribute(:last_crawl_status, RssFeedUrl::OK_STATUS)
      end

      specify { expect(rss_feed.has_errors?).to be false }
    end
  end

  describe '#has_pending?' do
    let(:rss_feed) do
      affiliates(:power_affiliate).rss_feeds.create!(name: 'Everything is pending',
                                                     rss_feed_urls: [rss_feed_urls(:white_house_press_gallery_url)])
    end

    context 'when one or more RssFeedUrls is in a pending state' do
      before do
        rss_feed.rss_feed_urls.first.update_attribute(:last_crawl_status, RssFeedUrl::PENDING_STATUS)
      end

      specify { expect(rss_feed.has_pending?).to be true }
    end

    context 'when no RssFeedUrl is in a pending state' do
      before do
        rss_feed.rss_feed_urls.each { |rfu| rfu.update_attribute(:last_crawl_status, RssFeedUrl::OK_STATUS) }
      end

      specify { expect(rss_feed.has_pending?).to be false }
    end
  end

  describe '.find_existing_or_initialize' do
    let(:name) { 'name' }
    let(:url) { rss_feed_urls(:white_house_press_gallery_url).url }
    let(:rfu) { [ ] }
    let(:affiliate) { affiliates(:basic_affiliate) }

    subject { affiliate.rss_feeds.find_existing_or_initialize(name, url) }

    context 'when there are no rss_feeds records' do
      it { is_expected.to be_a(described_class) }
      it { is_expected.to be_new_record }
      its(:name) { should eq(name) }
    end

    context 'when some rss_feeds records exist' do
      let(:created_name) { name }
      let(:rss_feed) do
        affiliate.rss_feeds.create!(name: created_name, rss_feed_urls: rfu)
      end

      before { rss_feed }

      context 'when the RSS feed has the same name but no matching URLs' do
        let(:rfu) { [rss_feed_urls(:white_house_blog_url)] }
        it { is_expected.to be_a(described_class) }
        it { is_expected.to be_new_record }
        its(:name) { should eq(name) }
      end

      context 'when the RSS feed has a different name but matching URLs' do
        let(:created_name) { 'other name' }
        let(:rfu) { [rss_feed_urls(:white_house_press_gallery_url)] }
        it { is_expected.to be_a(described_class) }
        it { is_expected.to be_new_record }
        its(:name) { should eq(name) }
      end

      context 'when the RSS feed has the same name and exactly one matching URL' do
        let(:rfu) { [rss_feed_urls(:white_house_press_gallery_url)] }
        it { is_expected.to eq(rss_feed) }
        it { is_expected.not_to be_new_record }
      end

      context 'when the RSS feed has the same name and multiple matching name/URL pairs' do
        let(:rfu) { [rss_feed_urls(:white_house_press_gallery_url)] }

        before do
          affiliate.rss_feeds.create!(name: created_name, rss_feed_urls: rfu) # again
          affiliate.rss_feeds.create!(name: created_name, rss_feed_urls: rfu) # and again
        end

        it { is_expected.to eq(rss_feed) }
        it { is_expected.not_to be_new_record }
      end
    end

    context 'when RSS feed URLs are duplicated' do
      let(:urls) { ['http://RSS.NYTIMES.COM/services/xml/rss/nyt/HomePage.xml'] }
      let(:normalized_urls) { urls.map { |u| UrlParser.normalize(u) } }
      let(:dup_attributes) do
        i = 0
        a = affiliates(:basic_affiliate)
        {
          owner_id: a.id,
          owner_type: a.class.name.to_s,
          name: 'Blog',
          rss_feed_urls_attributes: urls.inject({}) do |memo, u|
            memo[i.to_s] = {'url' => u, 'rss_feed_owner_type' => a.class.name.to_s}
            # same-same, but different.
            memo[(i+1).to_s] = {'url' => UrlParser.normalize(u), 'rss_feed_owner_type' => a.class.name.to_s}
            i += 2
            memo
          end
        }
      end

      before do
        allow_any_instance_of(RssFeedUrl).to receive(:url_must_point_to_a_feed) { true }
      end

      it 'should reject the save of the RSS feed URLs' do
        rss = affiliate.rss_feeds.build(dup_attributes)
        expect(rss.valid?).to be false
        expect(rss.errors[:rss_feed_urls]).to include("The following RSS feed URL has been duplicated: #{normalized_urls[0]}. Each RSS feed URL should be added only once.")
      end

      context 'when more than one RSS feed URL is duplicated' do
        let(:urls) { [rss_feed_urls(:white_house_press_gallery_url), rss_feed_urls(:whitehouse_youtube_url)].map(&:url) }

        it 'should reject the save of the RSS feed URLs' do
          rss = affiliate.rss_feeds.build(dup_attributes)
          expect(rss.valid?).to be false
          expect(rss.errors[:rss_feed_urls]).to include("The following RSS feed URLs have been duplicated: #{normalized_urls[0]}, #{normalized_urls[1]}. Each RSS feed URL should be added only once.")
        end
      end
    end
  end

  describe '#dup' do
    subject(:original_instance) { rss_feeds(:white_house_blog) }
    include_examples 'dupable', %w(owner_id)
  end
end
