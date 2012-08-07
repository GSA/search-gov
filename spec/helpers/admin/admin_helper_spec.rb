require 'spec_helper'

describe Admin::AdminHelper do

  describe "#affiliates_export_column(feature)" do
    fixtures :features, :affiliates
    before do
      @feature = features(:sayt)
      affiliates(:power_affiliate).features << @feature
      affiliates(:basic_affiliate).features << @feature
    end

    it "should return a comma-delimited string of alphabetized affiliate names using that feature" do
      helper.affiliates_export_column(@feature).should == 'noaa.gov,nps.gov'
    end
  end
end
