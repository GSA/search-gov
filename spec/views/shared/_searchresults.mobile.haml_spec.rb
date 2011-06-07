require 'spec/spec_helper'
describe "shared/_searchresults.mobile.haml" do

  before do
    @search = stub("Search")
    @search.stub!(:related_search).and_return []
    @search.stub!(:queried_at_seconds).and_return(1271978870)
    @search.stub!(:query).and_return "tax forms"
    @search.stub!(:spelling_suggestion)
    @search.stub!(:images).and_return []
    @search.stub!(:error_message)
    @search.stub!(:startrecord).and_return 1
    @search.stub!(:endrecord).and_return 10
    @search.stub!(:total).and_return 20
    @search.stub!(:page).and_return 0
    @search.stub!(:spotlight)
    @search.stub!(:boosted_contents)
    @search.stub!(:faqs)
    @search.stub!(:gov_forms)
    @search.stub!(:scope_id)
    @search.stub!(:fedstates)
    @search.stub!(:recalls)
    @search.stub!(:agency)
    @search.stub!(:extra_image_results)
    @search.stub!(:med_topic)
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

  end

end
