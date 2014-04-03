require 'spec_helper'

describe FlickrPhoto do
  fixtures :affiliates, :flickr_profiles

  before do
    @valid_attributes = {
      :flickr_id => '12345678'
    }
    @affiliate = affiliates(:basic_affiliate)
    @flickr_profile = flickr_profiles(:group)
  end

  it { should validate_presence_of :flickr_id }
  it { should validate_presence_of :flickr_profile }

  it "should create a new instance given valid attributes" do
    FlickrPhoto.create!(@valid_attributes.merge(:flickr_profile => @flickr_profile))
    should validate_uniqueness_of(:flickr_id).scoped_to(:flickr_profile_id)
  end

end
