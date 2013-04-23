require 'spec_helper'

describe ImageSearch do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:usagov_affiliate)
  end

  describe "#run" do
    before do
      @search = ImageSearch.new(:query => 'shuttle', :affiliate => @affiliate)
    end

    it "should log info about the query" do
      QueryImpression.should_receive(:log).with(:image, @affiliate.name, 'shuttle', %w{IMAG})
      @search.run
    end

    context "when there are no Bing or Flickr results" do
      before do
        @noresults_search = ImageSearch.new(:query => 'shuttle', :affiliate => @affiliate)
        @noresults_search.stub!(:search).and_return {}
      end

      it "should assign a nil module_tag" do
        @noresults_search.run
        @noresults_search.module_tag.should be_nil
      end
    end

    context 'when the affiliate has no Bing results, but has Flickr images' do
      before do
        @non_affiliate = affiliates(:non_existent_affiliate)
        @non_affiliate.site_domains.create(:domain => 'nonsense.com')
        flickr_profile = FlickrProfile.create(:url => 'http://flickr.com/photos/USAgency', :affiliate => @non_affiliate, :profile_type => 'user', :profile_id => '12345')
        FlickrPhoto.create!(:flickr_id => 5, :flickr_profile => flickr_profile, :title => 'President Obama walks his daughters to school', :description => '', :tags => 'barack obama,sasha,malia')
        FlickrPhoto.create!(:flickr_id => 6, :flickr_profile => flickr_profile, :title => 'POTUS gets in car.', :description => 'Barack Obama gets into his super protected car.', :tags => "car,batman", :date_taken => Time.now - 14.days)
        FlickrPhoto.create!(:flickr_id => 7, :flickr_profile => flickr_profile, :title => 'irrelevant photo', :description => 'irrelevant', :tags => "car,batman", :date_taken => Time.now - 14.days)
        FlickrPhoto.reindex
      end

      it 'should fill the results with the flickr photos' do
        search = ImageSearch.new(:query => 'obama', :affiliate => @non_affiliate)
        search.run
        search.results.should_not be_empty
        search.total.should == 2
        search.module_tag.should == 'FLICKR'
        search.results.first['title'].should == 'President Obama walks his daughters to school'
        search.results.last['title'].should == 'POTUS gets in car.'
      end

      it 'should log info about the query' do
        QueryImpression.should_receive(:log).with(:image, @non_affiliate.name, 'obama', %w{FLICKR})
        search = ImageSearch.new(:query => 'obama', :affiliate => @non_affiliate)
        search.run
      end
    end
  end

  subject do
    search = ImageSearch.new(:query => "White House", :affiliate => @affiliate)
    body = File.read(Rails.root.to_s + "/spec/fixtures/json/bing_image_results_for_white_house.json")
    search.stub!(:search).and_return(Hashie::Rash.new(JSON.parse(body)).search_response)
    search.run
    search
  end

  describe "#total" do
    it "is correct" do
      subject.total.should == 4340000
    end
  end

  describe "#results" do
    before do
      @result = subject.results.first
    end

    it "should ignore results with missing Thumbnail data" do
      subject.results.size.should==9
    end

    it "includes original image meta-data" do
      @result["title"].should == "White House, Washington D.C."
      @result["Url"].should == "http://biglizards.net/blog/archives/2008/08/"
      @result["DisplayUrl"].should == "http://biglizards.net/blog/archives/2008/08/"
      @result["Width"].should == 391
      @result["Height"].should == 428
      @result["FileSize"].should == 37731
      @result["ContentType"].should == "image/jpeg"
      @result["MediaUrl"].should == "http://biglizards.net/Graphics/ForegroundPix/White_House.JPG"
    end

    it "includes thumbnail meta-data" do
      @result["Thumbnail"]["Url"].should == "http://ts1.mm.bing.net/images/thumbnail.aspx?q=1581721453740&id=869b85a01b58c5a200496285e0144df1"
      @result["Thumbnail"]["FileSize"].should == 4719
      @result["Thumbnail"]["Width"].should == 146
      @result["Thumbnail"]["Height"].should == 160
      @result["Thumbnail"]["ContentType"].should == "image/jpeg"
    end

  end

end