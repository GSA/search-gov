require "#{File.dirname(__FILE__)}/../spec_helper"

describe PopularImageQuery do
  fixtures :popular_image_queries

  describe "Creating new instance" do
    should_validate_uniqueness_of :query
    should_validate_presence_of :query

    it "should create a new instance given valid attributes" do
      PopularImageQuery.create!(:query => "obama")
    end
  end

end
