require 'spec_helper'

describe FeaturedCollectionKeyword do
  fixtures :affiliates, :users, :featured_collections

  it { should validate_presence_of :value }
  it { should belong_to :featured_collection }
  it { should_not allow_value("piped|keywords").for(:value) }
  it { should_not allow_value("comma,separated,keywords").for(:value) }

  describe "validates uniqueness of keyword scoped to featured collection" do
    before do
      featured_collections(:basic).featured_collection_keywords.create!(:value => 'hurricane')
    end

    it { should validate_uniqueness_of(:value).scoped_to(:featured_collection_id).case_insensitive }
  end
end
