require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "shared/_searchresults.html.haml" do
  before do
    @search = stub("Search")
    @search.stub!(:related_search).and_return []
    @search.stub!(:queried_at_seconds).and_return(1271978870)
    @search.stub!(:query).and_return "tax forms"
    @search.stub!(:spelling_suggestion).and_return nil
    @search.stub!(:images).and_return []
    @search.stub!(:error_message).and_return nil
    @search.stub!(:startrecord).and_return 1
    @search.stub!(:endrecord).and_return 10
    @search.stub!(:total).and_return 20
    @search.stub!(:page).and_return 0
    @search.stub!(:spotlight).and_return nil
    @search.stub!(:boosted_sites).and_return nil
    @search.stub!(:faqs).and_return nil
    @search.stub!(:gov_forms).and_return nil
    @search.stub!(:scope_id).and_return nil
    @search.stub!(:fedstates).and_return nil
    @deepLink.stub!(:title).and_return 'A title'
    @deepLink.stub!(:url).and_return 'http://adeeplink.com'
    @search_result = {'title' => "some title",
                     'unescapedUrl'=> "http://www.foo.com/url",
                     'content'=> "This is a sample result",
                     'cacheUrl'=> "http://www.cached.com/url",
                     'deepLinks' => [ @deepLink ]
    }
    @search_results = []
    @search_results.stub!(:total_pages).and_return 1
    @search.stub!(:results).and_return @search_results

    20.times { @search_results << @search_result }
    assigns[:search] = @search
  end

  context "when page is displayed" do

    it "should show a results summary" do
      render :locals => { :search => @search }
      response.should contain("Results 1-10 of about 20 for 'tax forms'")
    end

    it "should show deep links on the first page only" do
      render :locals => { :search => @search }
      response.should have_tag('table', :class => 'deep_links', :count => 1 )
    end

    context "when on anything but the first page" do
      before do
        @search.stub!(:page).and_return 1
      end

      it "should not show any deep links" do
        render :locals => { :search => @search }
        response.should_not have_tag('table', :class => 'deep_links')
      end
    end

  end

end