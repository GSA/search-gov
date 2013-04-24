require 'spec_helper'

describe GovboxSet do
  fixtures :affiliates, :agencies

  describe ".new(query, affiliate, geoip_info)" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:agency) { agencies(:irs) }
    let(:geoip_info) { GeoipLookup.lookup('216.102.95.101') }

    it 'should assign boosted contents' do
      BoostedContent.stub!(:search_for).with('foo', affiliate).and_return "BoostedContent results"
      govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
      govbox_set.boosted_contents.should == "BoostedContent results"
    end

    it 'should assign featured collections' do
      FeaturedCollection.stub!(:search_for).with('foo', affiliate).and_return "FeaturedCollection results"
      govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
      govbox_set.featured_collections.should == "FeaturedCollection results"
    end

    context 'when affiliate is agency govbox enabled' do
      before do
        affiliate.stub!(:is_agency_govbox_enabled?).and_return true
      end

      context 'when query matches an agency' do
        before do
          AgencyQuery.create!(:phrase => 'foo', :agency => agency)
        end

        it 'should assign agency' do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.agency.should == agency
        end
      end

      context 'when query does not match an agency' do
        it 'should assign nil agency' do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.agency.should be_nil
        end
      end
    end

    context 'when affiliate is not agency govbox enabled' do
      before do
        affiliate.stub!(:is_agency_govbox_enabled?).and_return false
      end

      it 'should assign nil agency' do
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.agency.should be_nil
      end
    end

    context "when the affiliate has the jobs govbox enabled" do
      before do
        affiliate.stub!(:jobs_enabled?).and_return(true)
      end

      context "when the affiliate has a related agency with an org code" do
        before do
          affiliate.stub!(:agency).and_return(agency)
        end

        it "should call Usajobs.search with the query, org code, size, hl, and geoip_info params" do
          Usajobs.should_receive(:search).
            with(:query => 'foo', :hl => 1, :size => 3, :organization_id => 'ABCD', :geoip_info => geoip_info).
            and_return "jobs info"
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.jobs.should == "jobs info"
        end
      end

      context "when the affiliate does not have a related agency with an org code" do
        it "should call Usajobs.search with just the query, size, hl, and geoip_info param" do
          Usajobs.should_receive(:search).with(:query => 'foo', :hl => 1, :size => 3, :geoip_info => geoip_info).and_return nil
          GovboxSet.new('foo', affiliate, geoip_info)
        end
      end
    end

    context "when the affiliate does not have the jobs govbox enabled" do
      before do
        affiliate.stub!(:jobs_enabled?).and_return(false)
      end

      it 'should assign nil jobs' do
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.jobs.should be_nil
      end
    end

    context "when an affiliate has RSS Feeds" do
      before do
        affiliate.rss_feeds.each { |feed| feed.update_attribute(:shown_in_govbox, true) }
        @non_video_results = mock('non video results', :total => 3)
        NewsItem.should_receive(:search_for).with('foo', affiliate.rss_feeds.govbox_enabled.non_videos.to_a, a_kind_of(Time), 1).and_return(@non_video_results)

        @video_results = mock('video results', :total => 3)
        NewsItem.should_receive(:search_for).with('foo', affiliate.rss_feeds.govbox_enabled.videos.to_a, nil, 1).and_return(@video_results)
      end

      it "should retrieve govbox-enabled non-video and video RSS feeds" do
        govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
        govbox_set.news_items.should == @non_video_results
        govbox_set.video_news_items.should == @video_results
      end

    end

    context "med topics" do
      fixtures :med_topics
      context "when the affiliate has the medline govbox enabled" do

        before do
          affiliate.stub!(:is_medline_govbox_enabled?).and_return true
        end

        context "when the search matches a MedTopic record" do
          it "should retrieve the associated Med Topic record" do
            govbox_set = GovboxSet.new('ulcerative colitis', affiliate, geoip_info)
            govbox_set.med_topic.should == med_topics(:ulcerative_colitis)
          end

          context "when the locale is not the default" do
            before do
              I18n.locale = :es
            end

            it "should retrieve the spanish version of the med topic" do
              govbox_set = GovboxSet.new('Colitis ulcerativa', affiliate, geoip_info)
              govbox_set.med_topic.should == med_topics(:ulcerative_colitis_es)
            end

            after do
              I18n.locale = I18n.default_locale
            end
          end

        end

        context "when the query does not match a med topic" do
          it "should not set the med topic" do
            govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
            govbox_set.med_topic.should be_nil
          end
        end
      end

      context "when the affiliate does not have the medline govbox enabled" do
        before do
          affiliate.stub!(:is_medline_govbox_enabled?).and_return false
        end

        it "should not set the med topic" do
          govbox_set = GovboxSet.new('ulcerative colitis', affiliate, geoip_info)
          govbox_set.med_topic.should be_nil
        end
      end
    end

    describe "twitter" do
      context "when affiliate is twitter govbox enabled" do
        before do
          affiliate.stub!(:is_twitter_govbox_enabled?).and_return true
        end

        context "when affiliate has Twitter Profiles" do
          before do
            affiliate.twitter_profiles.create!(:screen_name => 'USASearch',
                                               :name => 'Test',
                                               :twitter_id => 123,
                                               :profile_image_url => 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png')
            Tweet.should_receive(:search_for).with('foo', [123], an_instance_of(ActiveSupport::TimeWithZone)).and_return 'Twitter stuff'
          end

          it "should find the most recent relevant tweet" do
            govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
            govbox_set.tweets.should == 'Twitter stuff'
          end
        end

        context "when affiliate has no Twitter Profiles" do
          it "should not set tweets" do
            govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
            govbox_set.tweets.should be_nil
          end
        end

      end

      context "when affiliate is not twitter govbox enabled" do
        before do
          affiliate.stub!(:is_twitter_govbox_enabled?).and_return false
        end

        it "should not set tweets" do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.tweets.should be_nil
        end
      end
    end

    describe "photos" do
      before do
        FlickrPhoto.stub!(:search_for).with('foo', affiliate).and_return "FlickrPhoto results"
      end

      context "when the affiliate has photo govbox enabled" do
        before do
          affiliate.update_attributes(:is_photo_govbox_enabled => true)
        end

        it "should find relevant photos" do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.photos.should == "FlickrPhoto results"
        end
      end

      context "when the affiliate does not have photo govbox enabled" do
        before do
          affiliate.update_attributes(:is_photo_govbox_enabled => false)
        end

        it "should not search for Flickr Photos" do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.photos.should be_nil
        end
      end
    end

    describe 'forms' do

      context 'when the affiliate has form_agencies' do
        before do
          affiliate.stub!(:form_agency_ids).and_return [1, 2, 3]
          Form.stub!(:govbox_search_for).with('foo', affiliate.form_agency_ids).and_return "Form results"
        end

        it 'should assign relevant forms' do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.forms.should == 'Form results'
        end
      end

      context 'when the affiliate does not have form_agencies' do
        it 'should assign forms with nil' do
          govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
          govbox_set.forms.should be_nil
        end
      end
    end

    it 'should assign related searches' do
      SaytSuggestion.stub!(:related_search).with('foo', affiliate).and_return "related search results"
      govbox_set = GovboxSet.new('foo', affiliate, geoip_info)
      govbox_set.related_search.should == "related search results"
    end

  end
end