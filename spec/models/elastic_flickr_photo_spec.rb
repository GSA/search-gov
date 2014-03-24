require 'spec_helper'

describe ElasticFlickrPhoto do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:flickr_profile) { FlickrProfile.create!(url: 'http://www.flickr.com/groups/usagov/', affiliate: affiliate, profile_type: 'user', profile_id: '12345') }

  before do
    ElasticFlickrPhoto.recreate_index
    FlickrPhoto.delete_all
    affiliate.locale = 'en'
  end

  it_behaves_like "an indexable"

  describe ".search_for" do
    describe "results structure" do
      context 'when there are results' do
        before do
          FlickrPhoto.create!(flickr_id: 1, flickr_profile: flickr_profile, title: 'Tropical Hurricane Names',
                              description: 'This is a bunch of names', tags: 'one,two')
          FlickrPhoto.create!(flickr_id: 2, flickr_profile: flickr_profile, title: 'More Hurricane names involving tropical',
                              description: 'This is a bunch of other names')
          ElasticFlickrPhoto.commit
        end

        it 'should return results in an easy to access structure' do
          search = ElasticFlickrPhoto.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 1, offset: 1, language: affiliate.locale)
          search.total.should == 2
          search.results.size.should == 1
          search.results.first.should be_instance_of(FlickrPhoto)
          search.offset.should == 1
        end

        context 'when those results get deleted' do
          before do
            flickr_profile.flickr_photos.destroy_all
            ElasticFlickrPhoto.commit
          end

          it 'should return zero results' do
            search = ElasticFlickrPhoto.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 1, offset: 1, language: affiliate.locale)
            search.total.should be_zero
            search.results.size.should be_zero
          end
        end
      end

    end
  end

  describe "highlighting results" do
    before do
      FlickrPhoto.create!(flickr_id: 1, flickr_profile: flickr_profile, title: 'Tropical Hurricane Names',
                          description: 'Worldwide Tropical Cyclone Names', tags: 'one,two')
      ElasticFlickrPhoto.commit
    end

    context 'when no highlight param is sent in' do
      it 'should highlight appropriate fields with <strong> by default' do
        search = ElasticFlickrPhoto.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.locale)
        first = search.results.first
        first.title.should == "<strong>Tropical</strong> Hurricane Names"
        first.description.should == "Worldwide <strong>Tropical</strong> Cyclone Names"
      end
    end

    context 'when highlight is turned off' do
      it 'should not highlight matches' do
        search = ElasticFlickrPhoto.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.locale, highlighting: false)
        first = search.results.first
        first.title.should == "Tropical Hurricane Names"
        first.description.should == "Worldwide Tropical Cyclone Names"
      end
    end

    context 'when title is really long' do
      before do
        long_title = "President Obama overcame furious lobbying by big banks to pass Dodd-Frank Wall Street Reform, to prevent the excessive risk-taking that led to a financial crisis while providing protections to American families for their mortgages and credit cards."
        FlickrPhoto.create!(flickr_id: 1234, flickr_profile: flickr_profile, title: long_title,
                            description: 'Worldwide Tropical Cyclone Names', tags: 'one,two')
        ElasticFlickrPhoto.commit
      end

      it 'should show everything in a single fragment' do
        search = ElasticFlickrPhoto.search_for(q: 'president credit cards', affiliate_id: affiliate.id, language: affiliate.locale)
        first = search.results.first
        first.title.should == "<strong>President</strong> Obama overcame furious lobbying by big banks to pass Dodd-Frank Wall Street Reform, to prevent the excessive risk-taking that led to a financial crisis while providing protections to American families for their mortgages and <strong>credit</strong> <strong>cards</strong>."
      end
    end
  end

  describe "filters" do

    context 'when there are matches across affiliates' do
      let(:other_affiliate) { affiliates(:power_affiliate) }
      let(:other_flickr_profile) { FlickrProfile.create!(url: 'http://www.flickr.com/groups/usagov2/', affiliate: other_affiliate, profile_type: 'user', profile_id: '123456') }

      before do
        other_affiliate.locale = 'en'
        FlickrPhoto.create!(flickr_id: 900, flickr_profile: flickr_profile, title: 'Tropical Hurricane Names aff1',
                            description: 'Worldwide Tropical Cyclone Names', tags: 'one,two')
        FlickrPhoto.create!(flickr_id: 901, flickr_profile: other_flickr_profile, title: 'Tropical Hurricane Names aff2',
                            description: 'Worldwide Tropical Cyclone Names', tags: 'one,two')
        ElasticFlickrPhoto.commit
      end

      it "should return only matches for the given affiliate" do
        search = ElasticFlickrPhoto.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.locale)
        search.total.should == 1
        search.results.first.title.should =~ /aff1$/
      end
    end

  end

  describe "recall" do
    before do
      FlickrPhoto.create!(flickr_id: 1000, flickr_profile: flickr_profile, title: 'Obamå and Bideñ',
                          description: 'Yosemite publications spelling', tags: 'Corazón,fair pay act')
      ElasticFlickrPhoto.commit
    end

    describe 'tags' do
      it 'should be case insensitive' do
        ElasticFlickrPhoto.search_for(q: 'cORAzon', affiliate_id: affiliate.id, language: affiliate.locale).total.should == 1
      end

      it 'should perform ASCII folding' do
        ElasticFlickrPhoto.search_for(q: 'coràzon', affiliate_id: affiliate.id, language: affiliate.locale).total.should == 1
      end

      it 'should only match full keyword phrase' do
        ElasticFlickrPhoto.search_for(q: 'fair pay act', affiliate_id: affiliate.id, language: affiliate.locale).total.should == 1
        ElasticFlickrPhoto.search_for(q: 'fair pay', affiliate_id: affiliate.id, language: affiliate.locale).total.should be_zero
      end
    end

    describe "title and description" do
      it 'should be case insentitive' do
        ElasticFlickrPhoto.search_for(q: 'OBAMA', affiliate_id: affiliate.id, language: affiliate.locale).total.should == 1
        ElasticFlickrPhoto.search_for(q: 'BIDEN', affiliate_id: affiliate.id, language: affiliate.locale).total.should == 1
      end

      it 'should perform ASCII folding' do
        ElasticFlickrPhoto.search_for(q: 'øbåmà', affiliate_id: affiliate.id, language: affiliate.locale).total.should == 1
        ElasticFlickrPhoto.search_for(q: 'bîdéÑ', affiliate_id: affiliate.id, language: affiliate.locale).total.should == 1
      end

      context "when query contains problem characters" do
        ['"   ', '   "       ', '+++', '+-', '-+'].each do |query|
          specify { ElasticFlickrPhoto.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.locale).total.should be_zero }
        end

        %w(+++obama --obama +-obama).each do |query|
          specify { ElasticFlickrPhoto.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.locale).total.should == 1 }
        end
      end
    end
  end

end