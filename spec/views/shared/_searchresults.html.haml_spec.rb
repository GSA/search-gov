require 'spec/spec_helper'
describe "shared/_searchresults.html.haml" do
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
    @search.stub!(:featured_collections)
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


    context "when search is for an affiliate" do

      before do
        @affiliate = Affiliate.create!(
          :display_name => "My Awesome Site",
          :domains => "someaffiliate.gov",
          :website => "http://www.someaffiliate.gov",
          :header => "<table><tr><td>html layout from 1998</td></tr></table>",
          :footer => "<center>gasp</center>",
          :name => "someaffiliate"
        )
        @affiliate.affiliate_template = AffiliateTemplate.create!(:name => "basic_black", :stylesheet => "basic_black")
        @search.stub!(:affiliate).and_return @affiliate

        stub_template "shared/_featured_collections.html.haml" => "featured collections"
        @search.stub!(:featured_collections).and_return(mock('solr', :total => 1, :hits => [@hit]))

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

    context "when on anything but the first page" do
      before do
        @search.stub!(:page).and_return 1
        view.stub!(:search).and_return @search
      end

      it "should not show any deep links" do
        render
        rendered.should_not have_selector('table', :class => 'deep_links')
      end
      
      context "when boosted contents are present" do
        before do
          @search.stub!(:boosted_contents).and_return [mock(BoostedContent)]
        end
        
        it "should not show boosted contents" do
          render
          rendered.should_not have_selector('boosted_content')
        end
      end

      context "when featured collections are present" do
        before do
          @search.stub!(:featured_collections).and_return(mock('solr', :total => 1, :hits => [mock('hit')]))
          stub_template "shared/_featured_collections.html.haml" => "featured collections"
        end

        it "should not show featured collections" do
          render
          rendered.should_not contain('featured collections')
        end
      end

    context "when a spotlight is present" do
        before do
          @search.stub!(:spotlight).and_return mock(Spotlight)
        end
        
        it "should not show a spotlight" do
          render
          rendered.should_not have_selector('spotlight')
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
        @search.stub!(:boosted_contents).and_return boosted_contents_results
        view.stub!(:search).and_return @search
      end

      it "should render the page without an error, and without boosted Contents" do
        render
        rendered.should have_selector('div#boosted', :content => "")
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