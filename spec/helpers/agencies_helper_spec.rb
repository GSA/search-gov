require 'spec/spec_helper'

describe AgenciesHelper do
  describe "#agency_url_matches_by_locale" do
    before do
      @agency = Agency.create(:name => 'My Agency', :domain => 'myagency.gov')
      @agency.agency_urls << AgencyUrl.new(:url => 'http://www.myagency.gov/', :locale => 'en')
    end

    context "when the locale is neither english or spanish" do
      it "should return false" do
        helper.agency_url_matches_by_locale('http://www.myagency.gov/', @agency, :tk).should == false
      end
    end
  end

  describe "#display_agency_link" do
    it "should remove url protocol" do
      search = mock('search', { :query => 'space', :queried_at_seconds => Time.now.to_i, :spelling_suggestion => nil })
      result = { 'unescapedUrl' => 'http://www.whitehouse.gov' }
      helper.should_receive(:tracked_click_link).with(result['unescapedUrl'], 'www.whitehouse.gov', search, nil, 0, 'BWEB', :web, "class='link-to-full-url'").and_return('tracked')
      helper.display_agency_link(result, search, nil, 0, :web).should == 'tracked'
    end
  end
end

