require 'spec_helper'

describe LegacyImageSearch do
  fixtures :affiliates, :site_domains, :flickr_profiles

  describe "#run" do
    context "when there are no Bing/Google or Flickr results" do
      let(:affiliate) { affiliates(:usagov_affiliate) }
      let(:noresults_search) { LegacyImageSearch.new(query: 'shuttle', affiliate: affiliate) }

      before do
        noresults_search.stub!(:search).and_return {}
      end

      it "should assign a nil module_tag" do
        noresults_search.run
        noresults_search.module_tag.should be_nil
      end
    end

    context 'when the affiliate has no Bing/Google results, but has Flickr images' do
      let(:non_affiliate) { affiliates(:non_existent_affiliate) }

      before do
        flickr_profile = flickr_profiles(:another_user)
        FlickrPhoto.create!(:flickr_id => 5, :flickr_profile => flickr_profile, :title => 'President Obama walks his unusual image daughters to school', :description => '', :tags => 'barack obama,sasha,malia')
        FlickrPhoto.create!(:flickr_id => 6, :flickr_profile => flickr_profile, :title => 'POTUS gets in unusual image car.', :description => 'Barack Obama gets into his super protected car.', :tags => "car,batman", :date_taken => Time.now - 14.days)
        FlickrPhoto.create!(:flickr_id => 7, :flickr_profile => flickr_profile, :title => 'irrelevant photo', :description => 'irrelevant', :tags => "car,batman", :date_taken => Time.now - 14.days)
        ElasticFlickrPhoto.commit
      end

      it 'should fill the results with the flickr photos' do
        search = LegacyImageSearch.new(query: 'unusual image', affiliate: non_affiliate)
        search.run
        search.results.should_not be_empty
        search.total.should == 2
        search.module_tag.should == 'FLICKR'
        search.results.first['title'].should == 'POTUS gets in unusual image car.'
        search.results.last['title'].should == 'President Obama walks his unusual image daughters to school'
      end

      it 'should log info about the query' do
        QueryImpression.should_receive(:log).with(:image, non_affiliate.name, 'unusual image', %w{FLICKR})
        search = LegacyImageSearch.new(query: 'unusual image', affiliate: non_affiliate)
        search.run
      end
    end

    context 'when there are Bing/Google results' do
      let(:search) { LegacyImageSearch.new(:query => 'white house', :affiliate => affiliates(:non_existent_affiliate)) }

      it "should set total" do
        search.run
        search.total.should == 4340000
      end

      it "should ignore results with missing Thumbnail data" do
        search.run
        search.results.size.should==9
      end

      it "includes original image meta-data" do
        search.run
        result = search.results.first
        result["title"].should == "White House, Washington D.C."
        result["Url"].should == "http://biglizards.net/blog/archives/2008/08/"
        result["DisplayUrl"].should == "http://biglizards.net/blog/archives/2008/08/"
        result["Width"].should == 391
        result["Height"].should == 428
        result["FileSize"].should == 37731
        result["ContentType"].should == "image/jpeg"
        result["MediaUrl"].should == "http://biglizards.net/Graphics/ForegroundPix/White_House.JPG"
      end

      it "includes thumbnail meta-data" do
        search.run
        result = search.results.first
        result["Thumbnail"]["Url"].should == "http://ts1.mm.bing.net/images/thumbnail.aspx?q=1581721453740&id=869b85a01b58c5a200496285e0144df1"
        result["Thumbnail"]["FileSize"].should == 4719
        result["Thumbnail"]["Width"].should == 146
        result["Thumbnail"]["Height"].should == 160
        result["Thumbnail"]["ContentType"].should == "image/jpeg"
      end

    end
  end

end
