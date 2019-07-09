# coding: utf-8
require 'spec_helper'

describe SiteCloner do
  fixtures :affiliates,
           :agencies,
           :boosted_contents,
           :document_collections,
           :featured_collections,
           :flickr_profiles,
           :i14y_drawers,
           :i14y_memberships,
           :image_search_labels,
           :instagram_profiles,
           :languages,
           :memberships,
           :navigations,
           :routed_queries,
           :routed_query_keywords,
           :rss_feed_urls,
           :rss_feeds,
           :twitter_profiles,
           :url_prefixes,
           :users,
           :youtube_profiles

  describe "target_handle" do
    context 'specified at initialization' do
      subject(:cloner) { SiteCloner.new(affiliates(:basic_affiliate), "my_choice") }

      its(:target_handle) { should eq('my_choice') }
    end

    context 'not specified at initialization' do
      context 'no prior copy exists' do
        subject(:cloner) { SiteCloner.new(affiliates(:basic_affiliate)) }

        its(:target_handle) { should eq("#{affiliates(:basic_affiliate).name}1") }
      end

      context 'existing site name is ridiculously long' do
        before do
          affiliates(:basic_affiliate).update_attribute(:name, "washingtonstateofficeofattorneyge")
        end
        subject(:cloner) { SiteCloner.new(affiliates(:basic_affiliate)) }

        its(:target_handle) { should eq("washingtonstateofficeofattorneyg1") }
      end

      context 'prior copy exists' do
        before do
          Affiliate.create!(
            display_name: 'My Awesome Site',
            name: "#{affiliates(:basic_affiliate).name}1",
            website: 'http://www.someaffiliate.gov',
            header: '<table><tr><td>html layout from 1998</td></tr></table>',
            footer: '<center>gasp</center>',
            locale: 'es'
          )
        end

        subject(:cloner) { SiteCloner.new(affiliates(:basic_affiliate)) }

        its(:target_handle) { should eq("#{affiliates(:basic_affiliate).name}2") }
      end
    end
  end

  describe "target_display_name" do
    subject(:cloner) { SiteCloner.new(affiliates(:basic_affiliate), "my_choice") }

    its(:target_display_name) { should eq("Copy of #{affiliates(:basic_affiliate).display_name}") }
  end

  describe '#clone' do
    let(:origin_site) do
      affiliate = affiliates(:basic_affiliate)
      affiliate.agency = agencies(:irs)
      affiliate.css_property_hash = {
        'title_link_color' => '#33ff33',
        'visited_title_link_color' => '#0000ff'
      }
      affiliate.external_tracking_code = '<script>var foo;</script>'
      affiliate.locale = 'ar'
      affiliate.theme = 'custom'
      affiliate.website = 'https://search.gov'
      affiliate.save!
      affiliate
    end

    let(:nav_attr_keys) { %w(is_active position).freeze }

    subject(:cloned_site) do
      site_cloner = SiteCloner.new(origin_site)
      cloned_instance = site_cloner.clone
      Affiliate.find cloned_instance.id
    end

    %i(agency
       css_property_hash
       external_tracking_code
       language
       theme
       user_ids
       website
       youtube_profile_ids).each do |attr|
      its(attr) { should eq(origin_site.send attr) }
    end

    context 'when the origin site has affiliate twitter settings' do
      before do
        origin_site.affiliate_twitter_settings.create!(show_lists: true,
                                                       twitter_profile_id: twitter_profiles(:usagov).id)
      end

      it 'copies the twitter settings' do
        expect(cloned_site.affiliate_twitter_settings.count).to eq(1)

        cloned_twitter_setting = cloned_site.affiliate_twitter_settings.first
        expect(cloned_twitter_setting.show_lists).to be true
        expect(cloned_twitter_setting.twitter_profile_id).to eq(twitter_profiles(:usagov).id)
      end
    end

    context 'when the origin site has boosted contents' do
      before do
        origin_site.boosted_contents.first.boosted_content_keywords.create!(value: 'cloning')
      end

      it 'copies the boosted contents' do
        expect(cloned_site.boosted_contents.count).to eq(2)

        origin_site.boosted_contents.each_with_index do |bc, index|
          cloned_bc = cloned_site.boosted_contents[index]

          excluded_params = { except: [:id, :affiliate_id] }
          expect(cloned_bc.as_json(excluded_params)).to eq(bc.as_json(excluded_params))

          actual_keywords = cloned_bc.boosted_content_keywords.pluck(:value)
          expected_keywords = bc.boosted_content_keywords.pluck(:value)
          expect(actual_keywords).to eq(expected_keywords)
        end
      end
    end

    context 'when the origin site has connections' do
      before do
        origin_site.connections.create!(connected_affiliate_id: affiliates(:gobiernousa_affiliate).id,
                                        label: 'español')
      end

      it 'copies the connections' do
        expect(cloned_site.connections.count).to eq(1)

        actual_connection = cloned_site.connections.first
        expected_connection = origin_site.connections.first
        expect(actual_connection.label).to eq(expected_connection.label)
        expect(actual_connection.connected_affiliate_id).to eq(expected_connection.connected_affiliate_id)
      end
    end

    it 'copies the document collections' do
      expect(cloned_site.document_collections.count).to eq(1)

      origin_site.document_collections.each_with_index do |dc, index|
        cloned_dc = cloned_site.document_collections[index]
        expect(cloned_dc.name).to eq(dc.name)

        actual_url_prefixes = cloned_dc.url_prefixes.pluck(:prefix)
        expected_url_prefixes = dc.url_prefixes.pluck(:prefix)
        expect(actual_url_prefixes).to eq(expected_url_prefixes)

        actual_nav_attrs = cloned_dc.navigation.attributes.slice(*nav_attr_keys)
        expected_nav_attrs = dc.navigation.attributes.slice(*nav_attr_keys)
        expect(actual_nav_attrs).to eq(expected_nav_attrs)
      end
    end

    context 'when the origin site has excluded URLs' do
      before do
        origin_site.excluded_urls.create!(url: 'http://do.not.include.gov/doc')
      end

      it 'copies excluded URLs' do
        expect(cloned_site.excluded_urls.count).to eq(1)
        expect(cloned_site.excluded_urls.first.url).to eq('http://do.not.include.gov/doc')
      end
    end

    context 'when the origin site has featured collections' do
      before do
        fc = origin_site.featured_collections.first
        fc.featured_collection_keywords.create!(value: 'cloning')
        fc.featured_collection_links.create!(position: 1,
                                             title: 'title',
                                             url: 'http://www.gov.gov/some.url')
      end

      it 'copies the featured collections' do
        expect(cloned_site.featured_collections.count).to eq(1)

        origin_site.featured_collections.each_with_index do |origin_fc, index|
          cloned_fc = cloned_site.featured_collections[index]

          excluded_params = { except: [:id, :affiliate_id] }
          expect(cloned_fc.as_json(excluded_params)).to eq(origin_fc.as_json(excluded_params))

          actual_keywords = cloned_fc.featured_collection_keywords.pluck(:value)
          expected_keywords = origin_fc.featured_collection_keywords.pluck(:value)
          expect(actual_keywords).to eq(expected_keywords)

          origin_fc.featured_collection_links.each_with_index do |origin_link, index|
            cloned_link = cloned_fc.featured_collection_links[index]
            excluded_params = { except: [:featured_collection_id, :id] }
            expect(cloned_link.as_json(excluded_params)).to eq(origin_link.as_json(excluded_params))
          end
        end
      end
    end

    it 'copies the Flickr profiles' do
      expect(cloned_site.flickr_profiles.count).to eq(1)

      origin_site.flickr_profiles.each_with_index do |fp, index|
        cloned_fp = cloned_site.flickr_profiles[index]
        expect(cloned_fp.profile_id).to eq(fp.profile_id)
        expect(cloned_fp.profile_type).to eq(fp.profile_type)
        expect(cloned_fp.url).to eq(fp.url)
      end
    end

    context 'when the origin site has i14y memberships' do
      before do
        origin_site.i14y_memberships.create!(i14y_drawer: i14y_drawers(:one))
      end

      it 'copies the i14y drawers' do
        expect(cloned_site.i14y_drawers.count).to eq(1)
        expect(cloned_site.i14y_drawers.pluck(:handle)).to eq(origin_site.i14y_drawers.pluck(:handle))
      end
    end

    context 'when the origin site has image search label with customized attributes' do
      before do
        origin_site.image_search_label.update_attributes!(name: 'my images')
        origin_site.image_search_label.navigation.update_attributes!(is_active: true)
      end

      it 'copies image search label' do
        actual_label = cloned_site.image_search_label
        expected_label = origin_site.image_search_label
        expect(actual_label.name).to eq(expected_label.name)

        actual_nav_attrs = actual_label.navigation.attributes.slice(*nav_attr_keys)
        expected_nav_attrs = expected_label.navigation.attributes.slice(*nav_attr_keys)
        expect(actual_nav_attrs).to eq(expected_nav_attrs)
      end
    end

    context 'when the origin site has indexed documents' do
      before do
        origin_site.indexed_documents.create!(description: 'This is a document.',
                                              title: 'Some Title',
                                              url: 'http://min.foo.gov/link.html')
      end

      it 'copies the indexed documents' do
        expect(cloned_site.indexed_documents.count).to eq(1)

        cloned_doc = cloned_site.indexed_documents.first
        expect(cloned_doc.description).to eq('This is a document.')
        expect(cloned_doc.title).to eq('Some Title')
        expect(cloned_doc.url).to eq('http://min.foo.gov/link.html')
      end
    end

    context 'when the origin site has instagram profiles' do
      before do
        origin_site.instagram_profiles << instagram_profiles(:whitehouse)
      end

      it 'copies the instagram profiles' do
        expect(cloned_site.instagram_profile_ids.count).to eq(1)
        expect(cloned_site.instagram_profile_ids).to eq(origin_site.instagram_profile_ids)
      end
    end

    it 'copies memberships' do
      user = users(:affiliate_manager)
      cloned_membership = cloned_site.memberships.find_by_user_id user.id
      expect(cloned_membership.gets_daily_snapshot_email).to be true
    end

    it 'copies navigations' do
      expect(cloned_site.navigations.count).to eq(origin_site.navigations.count)
    end

    context 'when the site has routed queries' do
      it 'copies the routed queries' do
        expect(cloned_site.routed_queries.count).to eq(2)

        origin_site.routed_queries.each_with_index do |rq, index|
          cloned_rq = cloned_site.routed_queries[index]
          expect(cloned_rq.description).to eq(rq.description)
          expect(cloned_rq.url).to eq(rq.url)

          actual_keywords = cloned_rq.routed_query_keywords.pluck(:keyword)
          expected_keywords = rq.routed_query_keywords.pluck(:keyword)
          expect(actual_keywords.count).to eq(2)
          expect(actual_keywords).to eq(expected_keywords)
        end
      end

      context 'when something goes wrong' do
        let(:cloner) { SiteCloner.new(origin_site) }
        before do
          allow(cloner).to receive(:clone_association_with_children) { true }
          allow(cloner).to receive(:clone_association_with_children).
            with(origin_site,anything,:routed_queries,:routed_query_keywords).
            and_raise(StandardError)
        end

        xit 're-enables the routed_query_keyword_observer' do
          expect(ActiveRecord::Base.observers).to receive(:enable).with(:routed_query_keyword_observer).and_call_original
          expect{cloner.clone}.to raise_error
        end
      end
    end

    it "copies the rss_feeds" do
      expect(cloned_site.rss_feeds.count).to eq(7)

      origin_site.rss_feeds.each_with_index do |rss_feed, index|
        cloned_rss_feed = cloned_site.rss_feeds[index]
        expect(cloned_rss_feed.name).to eq(rss_feed.name)

        actual_rss_feed_url_ids = cloned_rss_feed.rss_feed_urls.pluck(:id)
        expected_rss_feed_url_ids = rss_feed.rss_feed_urls.pluck(:id)
        expect(actual_rss_feed_url_ids).to eq(expected_rss_feed_url_ids)

        actual_nav_attrs = cloned_rss_feed.navigation.attributes.slice(*nav_attr_keys)
        expected_nav_attrs = rss_feed.navigation.attributes.slice(*nav_attr_keys)
        expect(actual_nav_attrs).to eq(expected_nav_attrs)
      end
    end

    context 'when the origin site has sayt suggestions' do
      before do
        origin_site.sayt_suggestions.create!(phrase: 'gov', popularity: 200)
      end

      it 'does not copy SAYT suggestions' do
        expect(cloned_site.sayt_suggestions.count).to eq(0)
      end
    end

    context 'when the origin site has site domains' do
      before do
        origin_site.site_domains = []
        origin_site.add_site_domains('foo.gov' => nil, 'bar.gov' => nil)
      end

      it 'copies the site_domains' do
        expect(cloned_site.site_domains.count).to eq(2)
        expect(cloned_site.site_domains.pluck(:domain)).to eq(origin_site.site_domains.pluck(:domain))
      end
    end

    context 'when the origin site has site feed URL' do
      before do
        origin_site.create_site_feed_url!(quota: 5,
                                          rss_url: 'http://some.gov/feed.xml')
      end

      it 'copies site feed URL' do
        expect(cloned_site.site_feed_url.quota).to eq(5)
        expect(cloned_site.site_feed_url.rss_url).to eq('http://some.gov/feed.xml')
      end
    end

    context 'the origin site has attached images' do
      let(:mock_image) { double("image", file?: true) }
      before do
        allow(origin_site).to receive(:page_background_image).and_return mock_image
        allow(origin_site).to receive(:header_image).and_return mock_image
        allow(origin_site).to receive(:mobile_logo).and_return mock_image
        allow(origin_site).to receive(:header_tagline_logo).and_return mock_image
      end

      it 'copies the images' do
        cloned_site = Affiliate.create!(display_name: 'cloned_site_with_images', name: 'cloned-site')
        cloner_handling_images = SiteCloner.new(origin_site)
        expect(cloner_handling_images).to receive(:create_site_shallow_copy).and_return(cloned_site)
        expect(cloned_site).to receive(:page_background_image=).with(mock_image)
        expect(cloned_site).to receive(:header_image=).with(mock_image)
        expect(cloned_site).to receive(:mobile_logo=).with(mock_image)
        expect(cloned_site).to receive(:header_tagline_logo=).with(mock_image)
        cloner_handling_images.clone
      end
    end

    context 'when the origin site has SC templates' do
      before do
        origin_site.affiliate_templates.create(template_id: Template.find_by_name("IRS").id)
        origin_site.affiliate_templates.create(template_id: Template.find_by_name("Classic").id)
        origin_site.update_attributes(template_id: Template.find_by_name("IRS").id)
      end

      it 'copies the templates' do
        expect(cloned_site.template.name).to eq('IRS')
        expect(cloned_site.available_templates.pluck(:name)).to match_array(['Classic','IRS'])
      end
    end
  end

  describe '#create_site_shallow_copy' do
    subject(:clone) { SiteCloner.new(affiliates(:basic_affiliate), 'my_choice').create_site_shallow_copy }

    its(:display_name) { should eq('Copy of NPS Site') }
    its(:name) { should eq('my_choice') }
  end
end
