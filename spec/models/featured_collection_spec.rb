require 'spec/spec_helper'

describe FeaturedCollection do
  fixtures :affiliates
  it { should validate_presence_of :title }

  SUPPORTED_LOCALES.each do |locale|
    it { should allow_value(locale).for(:locale) }
  end
  it { should_not allow_value("invalid_locale").for(:locale) }

  FeaturedCollection::STATUSES.each do |status|
    it { should allow_value(status).for(:status) }
  end
  it { should_not allow_value("bogus status").for(:locale) }

  it { should belong_to :affiliate }
  it { should have_many(:featured_collection_keywords).dependent(:destroy) }
  it { should have_many(:featured_collection_links).dependent(:destroy) }

  describe "#display_status" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:active_featured_collection) { affiliate.featured_collections.create!(:title => 'My awesome featured collection',
                                                                              :locale => 'en',
                                                                              :status => 'active') }
    let(:inactive_featured_collection) { affiliate.featured_collections.create!(:title => 'My awesome featured collection',
                                                                                :locale => 'en',
                                                                                :status => 'inactive') }
    specify { active_featured_collection.display_status.should == 'Active' }
    specify { inactive_featured_collection.display_status.should == 'Inactive' }
  end
end
