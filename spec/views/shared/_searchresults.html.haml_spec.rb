require 'spec_helper'

describe "shared/_searchresults.html.haml" do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:usagov_affiliate)
    assign(:affiliate, @affiliate)

    @search = double("WebSearch", has_photos?: false, med_topic: nil, jobs: nil,
                   has_boosted_contents?: false, has_related_searches?: false,
                   has_featured_collections?: false, has_video_news_items?: false,
                   has_news_items?: false, agency: nil, tweets: nil, query: "tax forms", affiliate: @affiliate,
                   page: 1, spelling_suggestion: nil, queried_at_seconds:1271978870,
                   error_message: nil, scope_id: nil, first_page?: true, matching_site_limits: [], module_tag:'BWEB',
                   startrecord: 1, endrecord: 10, total: 20)

    @search_result = {'title' => "some title",
                      'unescapedUrl' => "http://www.foo.com/url",
                      'content' => "This is a sample result",
                      'cacheUrl' => "http://www.cached.com/url"
    }
    @search_results = []
    20.times { @search_results << @search_result }
    @search_results.stub(:total_pages).and_return 1
    @search.stub(:results).and_return @search_results

    assign(:search, @search)
  end

  context "when page is displayed" do
    before do
      view.stub(:search).and_return @search
    end

    context "when featured collections are present" do
      before do
        stub_template "shared/_featured_collections.html.haml" => "featured collections"
        @search.stub(:has_boosted_contents?).and_return(false)
        @search.stub(:has_featured_collections?).and_return(true)
        @search.stub(:matching_site_limit).and_return("someaffiliate.gov")
      end

      it "should show featured collection" do
        render
        rendered.should contain('featured collections')
      end
    end

    context "when results are by USASearch" do
      it "should show the Bing logo" do
        render
        rendered.should have_selector("img[src^='/assets/searches/binglogo_en.gif']")
        rendered.should_not have_selector("a img[src^='/assets/searches/binglogo_en.gif']")
      end
    end

    context "when results are by USASearch" do
      before do
        @search.stub(:module_tag).and_return 'AIDOC'
        view.stub(:search).and_return @search
      end

      it "should show the English USASearch results by logo" do
        render
        rendered.should have_selector("a[href='https://search.gov'] img[src^='/assets/searches/results_by_usasearch_en.png']")
      end

      context "when the locale is Spanish" do
        before do
          I18n.stub(:locale).and_return :es
        end

        it "should show the Spanish USASearch results by logo" do
          render
          rendered.should have_selector("a[href='https://search.gov'] img[src^='/assets/searches/results_by_usasearch_es.png']")
        end
      end
    end

    context "when results are by Google" do
      before do
        @search.stub(:module_tag).and_return 'GWEB'
        view.stub(:search).and_return @search
      end

      it "should show the English Google results by logo" do
        render
        rendered.should have_selector("img[src^='/assets/searches/googlelogo_en.gif']")
        rendered.should_not have_selector("a img[src^='/assets/searches/googlelogo_en.gif']")
      end

      context "when the locale is Spanish" do
        before do
          I18n.stub(:locale).and_return :es
        end

        it "should show the Spanish Google results by logo" do
          render
          rendered.should have_selector("img[src^='/assets/searches/googlelogo_es.gif']")
          rendered.should_not have_selector("a img[src^='/assets/searches/googlelogo_es.gif']")
        end
      end
    end

    context "when on anything but the first page" do
      before do
        @search.stub(:page).and_return 2
        @search.stub(:first_page?).and_return false
        view.stub(:search).and_return @search
      end

      context "when boosted contents are present" do
        before do
          @search.should_not_receive(:has_boosted_contents?)
        end

        it "should not show boosted contents" do
          render
          rendered.should_not have_selector('boosted_content')
        end
      end

      context "when featured collections are present" do
        before do
          @search.should_not_receive(:has_featured_collections?)
        end

        it "should not show featured collections" do
          render
          rendered.should_not contain('featured collections')
        end
      end
    end
  end
end
