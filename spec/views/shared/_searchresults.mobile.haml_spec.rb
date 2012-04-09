require 'spec/spec_helper'
describe "shared/_searchresults.mobile.haml" do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:usagov_affiliate)
    assign(:affiliate, @affiliate)

    @search = stub("WebSearch")
    @search.stub!(:related_search).and_return []
    @search.stub!(:has_related_searches?).and_return false
    @search.stub!(:queried_at_seconds).and_return(1271978870)
    @search.stub!(:query).and_return "tax forms"
    @search.stub!(:spelling_suggestion)
    @search.stub!(:images).and_return []
    @search.stub!(:error_message)
    @search.stub!(:startrecord).and_return 1
    @search.stub!(:endrecord).and_return 10
    @search.stub!(:total).and_return 20
    @search.stub!(:page).and_return 1
    @search.stub!(:boosted_contents)
    @search.stub!(:scope_id)
    @search.stub!(:agency)
    @search.stub!(:med_topic)
    @search.stub!(:first_page?).and_return true
    @deep_link = mock("DeepLink")
    @deep_link.stub!(:title).and_return 'A title'
    @deep_link.stub!(:url).and_return 'http://adeeplink.com'

    @plain_search_result = {'title' => "some title",
                      'unescapedUrl'=> "http://www.foo.com/url",
                      'content'=> "This is a sample result",
                      'cacheUrl'=> "http://www.cached.com/url",
                      'deepLinks' => [@deep_link]
    }
    @pdf_search_result = {'title' => "some pdf title",
                      'unescapedUrl'=> "http://www.foo.com/url.pdf",
                      'content'=> "This is a sample pdf",
                      'cacheUrl'=> "http://www.cached.com/url.pdf",
                      'deepLinks' => [@deep_link]
    }
    @search_results = []
    @search_results.stub!(:total_pages).and_return 1
    @search.stub!(:results).and_return @search_results

    10.times {
      @search_results << @plain_search_result
      @search_results << @pdf_search_result
    }
    assign(:search, @search)
  end

  context "when page is displayed" do
    before do
      view.stub!(:search).and_return @search
    end

    it "should show a [PDF] in front of PDF links" do
      render
      rendered.should contain("some title")
      rendered.should contain("[PDF] some pdf title")
    end

    context "when on the first page for an affiliate with deep-links turned on" do
      it "should show deep links" do
        render
        rendered.should have_selector('table', :class => 'deep-links', :count => 1)
      end
    end

    context "when on the first page for an affiliate with deep-links turned off" do
      before do
        @affiliate.show_deep_links = false
      end

      it "should not show deep links" do
        render
        rendered.should_not have_selector('table', :class => 'deep-links')
      end
    end

  end

end
