require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "searches/index.html.haml" do
  before do
    @search = stub("Search")
    @search.stub!(:related_search).and_return []
    @search.stub!(:queried_at_seconds).and_return(1271978870)
    assigns[:search] = @search
  end

  context "when spelling suggestion is available" do
    before do
      @search.stub!(:query).and_return "U mispeled everytheeng"
      @search.stub!(:spelling_suggestion).and_return "You misspelled everything"
      @search.stub!(:results).and_return []
      @search.stub!(:boosted_sites).and_return nil
      @search.stub!(:faqs).and_return nil
      @search.stub!(:gov_forms).and_return nil
      @search.stub!(:spotlight).and_return nil
      @search.stub!(:error_message).and_return "Ignore me"
      @search.stub!(:filter_setting).and_return nil
      @search.stub!(:scope_id).and_return nil
    end

    it "should show the spelling suggestion" do
      render
      response.should contain("You misspelled everything")
    end
  end

  context "when there is a blank search" do
    before do
      @search.stub!(:query).and_return ""
      @search.stub!(:spelling_suggestion).and_return nil
      @search.stub!(:results).and_return []
      @search.stub!(:boosted_sites).and_return nil
      @search.stub!(:faqs).and_return nil
      @search.stub!(:gov_forms).and_return nil
      @search.stub!(:spotlight).and_return nil
      @search.stub!(:error_message).and_return "Enter some search terms"
      @search.stub!(:filter_setting).and_return nil
      @search.stub!(:scope_id).and_return nil
    end

    it "should show header search form but not show footer search form" do
      render
      response.should contain("Enter some search terms")
      response.should have_selector("#search_query_auto_complete")
      response.should_not have_selector("#footer_search_form")
    end
  end

  context "when there are search results" do
    before do
      @search.stub!(:query).and_return "some query"
      @search.stub!(:spelling_suggestion).and_return nil
      @search.stub!(:images).and_return []
      @search.stub!(:error_message).and_return nil
      @search.stub!(:startrecord).and_return 1
      @search.stub!(:endrecord).and_return "don't care"
      @search.stub!(:total).and_return "don't care"
      @search.stub!(:page).and_return 0
      @search_result = {'title' => "some title",
                       'unescapedUrl'=> "http://www.foo.com/url",
                       'content'=> "This is a sample result",
                       'cacheUrl'=> "http://www.cached.com/url"
      }
      @search_results = []
      @search_results.stub!(:total_pages).and_return 1
      @search.stub!(:results).and_return @search_results
      @search.stub!(:spotlight).and_return nil
      @search.stub!(:boosted_sites).and_return nil
      @search.stub!(:faqs).and_return nil
      @search.stub!(:gov_forms).and_return nil
      @search.stub!(:filter_setting).and_return nil
      @search.stub!(:scope_id).and_return nil
    end

    context "when there are fewer than five results" do
      before do
        4.times { @search_results << @search_result }
      end

      it "should show header search form but not show footer search form" do
        render
        response.should have_selector("#search_query_auto_complete")
        response.should_not have_selector("#footer_search_form")
      end
    end

    context "when there are five results" do
      before do
        5.times { @search_results << @search_result }
      end

      it "should show header search form and footer search form" do
        render
        response.should have_selector("#search_query_auto_complete")
        response.should have_selector("#footer_search_form")
      end
    end

    it "should not display a hidden filter parameter" do
      render
      response.should_not have_tag('input[type=?][name=?]', 'hidden', 'filter')
    end

    it "should not display a hidden fedstates parameter" do
      render
      response.should_not have_tag('input[type=?][name=?]', 'hidden', 'fedstates')
    end

    context "when a filter parameter is specified" do

      context "when the filter parameter is set to 'strict'" do
        before do
          @search.stub!(:filter_setting).and_return 'strict'
        end

        it "should include a hidden input field in the search form with the filter parameter" do
          render
          response.should have_tag('input[type=?][name=?][value=?]', 'hidden', 'filter', 'strict')
        end
      end

      context "when the filter parameter is set to 'off'" do
        before do
          @search.stub!(:filter_setting).and_return 'off'
        end

        it "should include a hidden input field in the search with the filter parameter set to 'off'" do
          render
          response.should have_tag('input[type=?][name=?][value=?]', 'hidden', 'filter', 'off')
        end
      end
    end

    context "when a scope id filter is set from the advanced form" do
      before do
        @search.stub!(:scope_id).and_return 'MD'
      end

      it "should include a hidden input field in the search with the fedstates value set to the scope id" do
        render
        response.should have_tag('input[type=?][name=?][value=?]', 'hidden', 'fedstates', 'MD')
      end

      it "should inform the user that the search was restricted" do
        5.times { @search_results << @search_result }
        render
        response.should contain(/This search was restricted/)
      end

      it "should link to a unrestricted version of the search" do
        render
        response.should_not have_tag('a[href=?]', /fedstates=MD/)
      end

      context "when the scope id is set to 'all'" do
        before do
          @search.stub!(:scope_id).and_return 'all'
        end

        it "should not show a restriction message" do
          render
          response.should_not contain(/This search was restricted/)
        end
      end
    end

  end
end
