require 'spec/spec_helper'

describe FeaturedCollectionLink do
  it { should validate_presence_of :title }
  it { should validate_presence_of :url }
  it { should belong_to :featured_collection }
end
