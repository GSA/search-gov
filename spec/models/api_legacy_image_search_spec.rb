require 'spec_helper'

describe ApiLegacyImageSearch do
  fixtures :affiliates, :site_domains, :flickr_profiles

  context 'when the affiliate has no Bing/Google results, but has Flickr images' do
    let(:non_affiliate) { affiliates(:non_existent_affiliate) }

    before do
      flickr_profile = flickr_profiles(:another_user)
      FlickrPhoto.create!(flickr_id: 5,
                          flickr_profile: flickr_profile,
                          title: 'President Obama walks his unusual image daughters to school',
                          description: '',
                          tags: 'barack obama,sasha,malia')
      FlickrPhoto.create!(flickr_id: 6,
                          flickr_profile: flickr_profile,
                          title: 'POTUS gets in unusual image car.',
                          description: 'Barack Obama gets into his super protected car.',
                          tags: 'car,batman',
                          date_taken: Time.now - 14.days)
      FlickrPhoto.create!(flickr_id: 7,
                          flickr_profile: flickr_profile,
                          title: 'irrelevant photo',
                          description: 'irrelevant',
                          tags: 'car,batman',
                          date_taken: Time.now - 14.days)
      ElasticFlickrPhoto.commit
    end

    it 'returns empty results' do
      search = ApiLegacyImageSearch.new(query: 'unusual image', affiliate: non_affiliate)
      search.run
      search.results.should be_empty
      search.total.should == 0
    end

  end
end
