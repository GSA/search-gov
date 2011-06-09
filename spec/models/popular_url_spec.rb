require 'spec_helper'

describe PopularUrl do
  fixtures :affiliates

  it { should validate_presence_of :title }
  it { should validate_presence_of :url }
  it { should validate_presence_of :rank }
  it { should belong_to :affiliate }

  describe "validates uniqueness of rank scoped to affiliate" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      PopularUrl.create!(:affiliate => @affiliate, :title => 'awesome third post', :url => 'http://example/blog/1', :rank => 1)
    end

    it { should validate_uniqueness_of(:rank).scoped_to(:affiliate_id) }
  end

  describe "#top_urls" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @third_url = PopularUrl.create!(:affiliate => @affiliate, :title => 'awesome third post', :url => 'http://example/blog/1', :rank => 5)
      @second_url = PopularUrl.create!(:affiliate => @affiliate, :title => 'awesome second post', :url => 'http://example/blog/2', :rank => 4)
      @first_url = PopularUrl.create!(:affiliate => @affiliate, :title => 'awesome first post', :url => 'http://example/blog/3', :rank => 3)
      @unrelated_url = PopularUrl.create!(:affiliate => affiliates(:power_affiliate), :title => 'awesome post', :url => 'http://example/blog/4', :rank => 1)
    end

    it "returns top N urls sorted by rank" do
      @affiliate.popular_urls.top_urls[0].should == @first_url
      @affiliate.popular_urls.top_urls[1].should == @second_url
      @affiliate.popular_urls.top_urls[2].should == @third_url
    end
  end
end
