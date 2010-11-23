require "#{File.dirname(__FILE__)}/../spec_helper"

describe SitePage do
  fixtures :site_pages

  describe "Creating new instance" do
    should_validate_uniqueness_of :url_slug
    should_validate_presence_of :url_slug

    it "should create a new instance given valid attributes" do
      SitePage.create!(:url_slug => "slug", :title=> "title", :breadcrumb => "breadcrumb", :main_content => "main_content")
    end
  end

  describe "#crawl_usa_gov" do
    before do
      site_index_doc = Hpricot(File.open(RAILS_ROOT + "/spec/fixtures/html/usa_gov/site_index.html"))
      agencies_doc = Hpricot(File.open(RAILS_ROOT + "/spec/fixtures/html/usa_gov/agencies.html"))
      audiences_doc = Hpricot(File.open(RAILS_ROOT + "/spec/fixtures/html/usa_gov/audiences.html"))
      SitePage.should_receive(:open).and_return(site_index_doc, agencies_doc, audiences_doc)
    end

    it "should generate SitePages from the USA.gov website" do
      SitePage.crawl_usa_gov
      SitePage.count.should == 3
      first = SitePage.find_by_url_slug "site_index"
      first.title.should == "Site Index"
      first.breadcrumb.should ==  "<a href=\"/\">Home</a> &gt; Site Index"
      first.main_content.should match(/^<h1 id.*<\/span> <\/li> <\/ul> <\/div> $/)
      second = SitePage.find_by_url_slug "Agencies/Federal/All_Agencies/index"
      second.title.should == "A-Z Index of U.S. Government Departments and Agencies"
      second.breadcrumb.should ==  "<a href=\"/\">Home</a> &gt; <a href=\"/usa/Topics/Audiences\">A-Z Index</a> &gt; A-Z Index of U.S. Government Departments and Agencies"
      second.main_content.should match(/^<h1 id.*make sure the crawler follows the breadcrumb links.*<\/script>$/)
      third = SitePage.find_by_url_slug "Topics/Audiences"
      third.title.should == "Especially for Specific Audiences"
      third.breadcrumb.should ==  "<a href=\"/\">Home</a> &gt; <a href=\"/\">Citizens</a> &gt; Especially for Specific Audiences"
      third.main_content.should match(/^<h1 id.*dead ends on the breadcrumb.*<\/script>$/)
    end

    context "when prior site pages exist" do
      before do
        SitePage.create!(:url_slug => "old slug", :title=> "old title", :breadcrumb => "old breadcrumb", :main_content => "old content")
      end

      it "should delete any prior site pages" do
        SitePage.crawl_usa_gov
        SitePage.exists?(:url_slug => "old slug", :title=> "old title", :breadcrumb => "old breadcrumb", :main_content => "old content").should be_false
      end
    end
  end

end
