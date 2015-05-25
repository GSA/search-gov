require 'spec_helper'

describe SiteCloner do
  fixtures :languages, :affiliates, :agencies, :site_domains, :rss_feeds, :rss_feed_urls,
           :document_collections, :url_prefixes, :navigations, :twitter_profiles,
           :youtube_profiles, :boosted_contents, :featured_collections, :i14y_drawers, :i14y_memberships,
           :users, :memberships

  describe "target_handle" do
    context 'specified at initialization' do
      subject(:cloner) { SiteCloner.new(affiliates(:basic_affiliate), "my_choice") }

      its(:target_handle) { should eq('my_choice') }
    end

    context 'not specified at initialization' do
      context 'no prior copy exists' do
        subject(:cloner) { SiteCloner.new(affiliates(:basic_affiliate)) }

        its(:target_handle) { should eq("#{affiliates(:basic_affiliate).name}-copy1") }
      end

      context 'prior copy exists' do
        before do
          Affiliate.create!(
            display_name: 'My Awesome Site',
            name: "#{affiliates(:basic_affiliate).name}-copy1",
            website: 'http://www.someaffiliate.gov',
            header: '<table><tr><td>html layout from 1998</td></tr></table>',
            footer: '<center>gasp</center>',
            locale: 'es'
          )
        end

        subject(:cloner) { SiteCloner.new(affiliates(:basic_affiliate)) }

        its(:target_handle) { should eq("#{affiliates(:basic_affiliate).name}-copy2") }
      end
    end
  end

  describe "target_display_name" do
    subject(:cloner) { SiteCloner.new(affiliates(:basic_affiliate), "my_choice") }

    its(:target_display_name) { should eq("#{affiliates(:basic_affiliate).display_name} (Copy)") }
  end

  describe '#clone' do
    let(:origin_site) do
      affiliate = affiliates(:basic_affiliate)
      affiliate.agency = agencies(:irs)
      affiliate.theme = 'custom'
      affiliate.locale = 'ar'
      affiliate.save!
      affiliate.add_site_domains('foo.gov' => nil, 'bar.gov' => nil)
      affiliate.twitter_profiles << twitter_profiles(:usagov)
      affiliate.boosted_contents.first.boosted_content_keywords.create!(value: 'cloning')
      affiliate.featured_collections.first.featured_collection_keywords.create!(value: 'cloning')
      affiliate.featured_collections.first.featured_collection_links.create!(position: 1, title: 'title', url: 'http://www.gov.gov/some.url')
      affiliate.i14y_memberships.create!(i14y_drawer: i14y_drawers(:one))
      affiliate
    end

    let(:clone) do
      site_cloner = SiteCloner.new(origin_site)
      site_cloner.clone
    end

    it "copies the website" do
      clone.website.should eq(origin_site.website)
    end

    it "copies the agency" do
      clone.agency.should eq(origin_site.agency)
    end

    it "copies the theme" do
      clone.theme.should eq(origin_site.theme)
    end

    it "copies the css_property_hash" do
      clone.css_property_hash.should eq(origin_site.css_property_hash)
    end

    it "copies the site_domains" do
      clone.site_domains.pluck(:domain).should eq(origin_site.site_domains.pluck(:domain))
    end

    it "copies the rss_feeds" do
      clone.rss_feeds.non_managed.count.should eq(origin_site.rss_feeds.non_managed.count)
      clone.rss_feeds.non_managed.each do |rss_feed|
        origin_feed = RssFeed.find_by_name(rss_feed.name)
        rss_feed_params = { except: [:created_at, :id, :updated_at, :owner_id] }
        rss_feed.as_json(rss_feed_params).should eq(origin_feed.as_json(rss_feed_params))
        rss_feed.rss_feed_urls.each do |rss_feed_url|
          origin_feed_url = RssFeedUrl.find_by_url(rss_feed_url.url)
          rss_feed_url_params = { except: [:created_at, :id, :updated_at, :last_crawled_at, :last_crawl_status] }
          rss_feed_url.as_json(rss_feed_url_params).should eq(origin_feed_url.as_json(rss_feed_url_params))
        end
      end
    end

    it 'copies the document collections' do
      clone.document_collections.count.should eq(origin_site.document_collections.count)
      clone.document_collections.each do |document_collection|
        origin_dc = DocumentCollection.find_by_name(document_collection.name)
        dc_params = { except: [:created_at, :id, :updated_at, :affiliate_id] }
        document_collection.as_json(dc_params).should eq(origin_dc.as_json(dc_params))
        document_collection.url_prefixes.each do |url_prefix|
          origin_url_prefix = UrlPrefix.find_by_prefix(url_prefix.prefix)
          url_prefix.prefix.should eq(origin_url_prefix.prefix)
        end
      end
    end

    it 'copies the Twitter profile IDs' do
      clone.twitter_profile_ids.should eq(origin_site.twitter_profile_ids)
    end

    it 'copies the Youtube profile IDs' do
      clone.youtube_profile_ids.should eq(origin_site.youtube_profile_ids)
    end

    it 'enables the video govbox' do
      clone.is_video_govbox_enabled.should be_true
    end

    it 'copies the boosted contents' do
      clone.boosted_contents.count.should eq(origin_site.boosted_contents.count)
      clone.boosted_contents.each do |boosted_content|
        origin_bc = BoostedContent.find_by_url(boosted_content.url)
        bc_params = { except: [:id, :affiliate_id] }
        boosted_content.as_json(bc_params).should eq(origin_bc.as_json(bc_params))
        boosted_content.boosted_content_keywords.pluck(:value).should eq(origin_bc.boosted_content_keywords.pluck(:value))
      end
    end

    it 'copies the featured collections' do
      clone.featured_collections.count.should eq(origin_site.featured_collections.count)
      clone.featured_collections.each do |featured_collection|
        origin_fc = FeaturedCollection.find_by_title(featured_collection.title)
        fc_params = { except: [:id, :affiliate_id] }
        featured_collection.as_json(fc_params).should eq(origin_fc.as_json(fc_params))
        featured_collection.featured_collection_keywords.pluck(:value).should eq(origin_fc.featured_collection_keywords.pluck(:value))
        featured_collection.featured_collection_links.each do |featured_collection_link|
          origin_featured_collection_link = FeaturedCollectionLink.find_by_title(featured_collection_link.title)
          fcl_params = { except: [:featured_collection_id, :id] }
          featured_collection_link.as_json(fcl_params).should eq(origin_featured_collection_link.as_json(fcl_params))
        end
      end
    end

    it "copies the i14y drawers" do
      clone.i14y_drawers.count.should eq(origin_site.i14y_drawers.count)
    end

    it 'copies the memberships' do
      clone.users.count.should eq(origin_site.users.count)
    end

    it 'copies the language' do
      clone.language.should eq(origin_site.language)
    end
  end
end
