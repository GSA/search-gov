require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FoodRecall do
  before(:each) do
    @valid_attributes = {
      :url => "http://www.fsis.usda.gov/News_&_Events/Recall_061_2009_Release/index.asp",
      :summary => "Iowa Firm Recalls Roast Beef Deli Products Due To Mislabeling And An Undeclared Allergen",
      :description => "Curly's Food, Inc., a Sioux City, Iowa, establishment, is recalling approximately 12,181 pounds of roast beef deli products because they were inadvertently mislabeled and contain an undeclared allergen, soy, the U.S. Department of Agriculture's Food Safety and Inspection Service (FSIS) announced today. Soy is a known potential allergen, which is not declared on the label."
    }
  end

  describe "creating new instance" do
    should_validate_presence_of :url, :summary, :description
    should_belong_to :recall

    it "should create a new instance given valid attributes" do
      FoodRecall.create!(@valid_attributes)
    end
  end

end
