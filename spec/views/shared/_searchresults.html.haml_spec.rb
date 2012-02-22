require 'spec/spec_helper'
describe "shared/_searchresults.html.haml" do
  before do
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
    @search.stub!(:has_boosted_contents?)
    @search.stub!(:faqs)
    @search.stub!(:gov_forms)
    @search.stub!(:scope_id)
    @search.stub!(:fedstates)
    @search.stub!(:recalls)
    @search.stub!(:agency)
    @search.stub!(:extra_image_results)
    @search.stub!(:med_topic)
    @search.stub!(:has_featured_collections?)
    @search.stub!(:indexed_documents)
    @search.stub!(:are_results_by_bing?).and_return true
    @search.stub!(:first_page?).and_return true
    @deep_link = mock("DeepLink")
    @deep_link.stub!(:title).and_return 'A title'
    @deep_link.stub!(:url).and_return 'http://adeeplink.com'

    @search_result = {'title' => "some title",
                      'unescapedUrl'=> "http://www.foo.com/url",
                      'content'=> "This is a sample result",
                      'cacheUrl'=> "http://www.cached.com/url",
                      'deepLinks' => [@deep_link]
    }
    @search_results = []
    @search_results.stub!(:total_pages).and_return 1
    @search.stub!(:results).and_return @search_results

    20.times { @search_results << @search_result }
    assign(:search, @search)
  end

  context "when page is displayed" do
    before do
      view.stub!(:search).and_return @search
    end

    it "should show a results summary" do
      render
      rendered.should contain("Results 1-10 of about 20 for 'tax forms'")
    end

    it "should show deep links on the first page only" do
      render
      rendered.should have_selector('table', :class => 'deep-links', :count => 1)
    end

    it "should contain cache links" do
      render
      rendered.should contain('Cache')
    end
    
    it "should show the Bing logo" do
      render
      rendered.should have_selector("img[src^='/images/binglogo_en.gif']")
    end

    context "when search is for an affiliate" do
      before do
        @affiliate = Affiliate.create!(
          :display_name => "My Awesome Site",
          :website => "http://www.someaffiliate.gov",
          :header => "<table><tr><td>html layout from 1998</td></tr></table>",
          :footer => "<center>gasp</center>",
          :name => "someaffiliate"
        )
        @affiliate.affiliate_template = AffiliateTemplate.create!(:name => "basic_black", :stylesheet => "basic_black")
        @search.stub!(:affiliate).and_return @affiliate

        stub_template "shared/_featured_collections.html.haml" => "featured collections"
        @search.stub!(:has_boosted_contents?).and_return(false)
        @search.stub!(:has_featured_collections?).and_return(true)
        @search.stub!(:matching_site_limit).and_return("someaffiliate.gov")

        view.stub!(:search).and_return @search
      end

      it "should not show any deep links" do
        render
        rendered.should_not contain('Cache')
      end

      it "should show featured collection" do
        render
        rendered.should contain('featured collections')
      end
    end
    
    context "when results are not by bing" do
      before do
        @search.stub!(:are_results_by_bing?).and_return false
        view.stub!(:search).and_return @search
      end
      
      it "should show the USASearch results by logo" do
        render
        rendered.should have_selector("img[src^='/images/results_by_usasearch_en.png']")
        rendered.should have_selector("a", :href => 'http://searchblog.usa.gov/')
      end
      
      context "when the locale is Spanish" do
        before do
          I18n.stub!(:locale).and_return :es
        end
        
        it "should not show a results-by logo" do
          render
          rendered.should have_selector("img[src^='/images/results_by_usasearch_es.png']")
          rendered.should have_selector("a", :href => 'http://searchblog.usa.gov/')
        end
      end
    end

    context "when on anything but the first page" do
      before do
        @search.stub!(:page).and_return 2
        @search.stub!(:first_page?).and_return false
        view.stub!(:search).and_return @search
      end

      it "should not show any deep links" do
        render
        rendered.should_not have_selector('table', :class => 'deep_links')
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

      context "when a recalls record is present" do
        before do
          @search.stub!(:recalls).and_return [mock(Recall)]
        end

        it "should not show a recalls govbox" do
          render
          rendered.should_not have_selector('govbox')
        end
      end

      context "when extra image results are present" do
        before do
          @search.stub!(:extra_image_results).and_return "ExtraImageResults"
        end

        it "should not show a popular image govbox" do
          render
          rendered.should_not have_selector('govbox')
        end
      end
    end

    context "when a boosted Content is returned as a hit, but that boosted Content is not in the database" do
      before do
        boosted_content = BoostedContent.create(:title => 'test', :url => 'http://test.gov', :description => 'test', :locale => 'en', :status => 'active', :publish_start_on => Date.current)
        BoostedContent.reindex
        boosted_content.delete
        boosted_contents_results = BoostedContent.search_for("test")
        boosted_contents_results.hits.first.instance.should be_nil
        @search.stub!(:has_boosted_contents?).and_return(true)
        @search.stub!(:boosted_contents).and_return boosted_contents_results
        view.stub!(:search).and_return @search
      end

      it "should render the page without an error, and without boosted Contents" do
        render
        rendered.should have_selector('div#boosted', :content => "")
        rendered.should_not have_selector('div#boosted .searchresult')
      end
    end

    context "when a recall is found" do
      before do
        recall = Recall.create!(:recall_number => '23456', :recalled_on => Date.yesterday, :organization => 'CPSC')
        recall.recall_details << RecallDetail.new(:detail_type => 'Description', :detail_value => 'Recall details')
        Recall.reindex
        @search.stub!(:recalls).and_return(Recall.search_for("details"))
        view.stub!(:search).and_return @search
      end

      it "should render a govbox with recall links" do
        render
        rendered.should have_selector('.recalls-govbox .details a', :content => "details")
      end
    end
  end
end