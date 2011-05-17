require 'spec/spec_helper'

describe PopularImageQuery do
  fixtures :popular_image_queries

  describe "Creating new instance" do
    it { should validate_uniqueness_of :query }
    it { should validate_presence_of :query }

    it "should create a new instance given valid attributes" do
      PopularImageQuery.create!(:query => "obama")
    end
  end

end
