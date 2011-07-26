require 'spec/spec_helper'

describe AgencyPopularUrl do

  it { should validate_presence_of :agency_id }
  it { should validate_presence_of :url }
  it { should validate_presence_of :title }
  it { should validate_presence_of :source }
  
  it "should default source to 'admin'" do
    agency = Agency.create!(:name => 'test.gov', :domain => 'test.gov')
    agency_popular_url = AgencyPopularUrl.create!(:url => 'http://test.gov', :title => 'Test', :rank => 12, :agency => agency)
    agency_popular_url.source.should == 'admin'
  end
  
  describe "#compute_for_date" do
    before do
      @bitly_api = mock(BitlyAPI)
      @bitly_api.stub!(:get_popular_links_for_domain).and_return []
      BitlyAPI.should_receive(:new).and_return @bitly_api
    end
    
    context "when no date is passed" do
      it "should grab the date specified and process the file" do
        @bitly_api.should_receive(:grab_csv_for_date).with(Date.yesterday).and_return "filename"
        @bitly_api.should_receive(:parse_csv).with("filename").and_return true
        AgencyPopularUrl.compute_for_date
      end
    end
    
    context "when a date is passed" do
      it "should grab the date specified and process the file" do
        date = Date.parse('2011-07-01')
        @bitly_api.should_receive(:grab_csv_for_date).with(date).and_return "filename"
        @bitly_api.should_receive(:parse_csv).with("filename").and_return true
        AgencyPopularUrl.compute_for_date(date)
      end
    end
    
    context "when popular links are returned" do
      before do
        @bitly_api.stub!(:get_popular_links_for_domain).and_return [{:long_url => 'http://search.usa.gov', :clicks => 100, :title => 'Search.USA.gov'}]
        @bitly_api.stub!(:grab_csv_for_date).and_return "filename"
        @bitly_api.stub!(:parse_csv).and_return true
      end
      
      context "when an agency is present" do
        before do
          Agency.destroy_all
          @agency = Agency.create!(:name => "Usa.gov", :domain => "usa.gov")
          @agency.agency_popular_urls << AgencyPopularUrl.new(:url => 'http://test.com', :title => "Test", :rank => 99, :source => 'bitly')
          @agency.agency_popular_urls << AgencyPopularUrl.new(:url => 'http://test.com/admin', :title => "Test", :rank => 99, :source => 'admin')
          @agency.agency_popular_urls.size.should == 2
        end
      
        it "should delete all the existing agency urls and add in those returned" do
          AgencyPopularUrl.compute_for_date
          @agency.reload
          @agency.agency_popular_urls.size.should == 2
          @agency.agency_popular_urls.last.url.should == "http://search.usa.gov"
        end
        
        context "when the link is already in the list" do
          before do
            @agency.agency_popular_urls << AgencyPopularUrl.new(:url => 'http://search.usa.gov', :title => "Test", :rank => 99, :source => 'admin')
          end
          
          it "should leave it as is" do
            AgencyPopularUrl.compute_for_date
            @agency.reload
            @agency.agency_popular_urls.size.should == 2
            @agency.agency_popular_urls.last.title.should == "Test"
            @agency.agency_popular_urls.last.rank.should == 99
          end
        end
      end
    end
  end    
end