require 'spec_helper'
describe "shared/_searchresults.mobile.haml" do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:usagov_affiliate)
    assign(:affiliate, @affiliate)

    @search = stub("WebSearch", has_boosted_contents?: false, has_related_searches?: false, query: "tax forms", affiliate: @affiliate,
                   page: 1, spelling_suggestion: nil, queried_at_seconds: 1271978870,
                   error_message: nil, scope_id: nil, first_page?: true, matching_site_limits: [], module_tag: 'BWEB',
                   startrecord: 1, endrecord: 10, total: 20)


    @plain_search_result = {'title' => "some title",
                            'unescapedUrl' => "http://www.foo.com/url",
                            'content' => "This is a sample result",
                            'cacheUrl' => "http://www.cached.com/url"
    }
    @pdf_search_result = {'title' => "some pdf title",
                          'unescapedUrl' => "http://www.foo.com/url.pdf",
                          'content' => "This is a sample pdf",
                          'cacheUrl' => "http://www.cached.com/url.pdf"
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
  end
end
