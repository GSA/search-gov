require 'spec/spec_helper'

describe Analytics::SearchModuleHelper do

  describe "#display_most_recent_daily_search_module_stats_date_available(day)" do
    context "when nil day parameter is passed in" do
      it "should return message saying no data is available" do
        helper.display_most_recent_daily_search_module_stats_date_available(nil).should == "Search module data currently unavailable"
      end
    end
  end

end
