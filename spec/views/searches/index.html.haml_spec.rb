require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "searches/index.html.haml" do
  before do
    @search = stub("Search")
    @search.stub!(:query).and_return "test"
    @search.stub!(:spelling_suggestion).and_return nil
    @search.stub!(:related_search).and_return []
    @search.stub!(:queried_at_seconds).and_return(1271978870)
    @search.stub!(:recalls)
    @search.stub!(:extra_image_results)
    @search.stub!(:results).and_return []
    @search.stub!(:boosted_contents).and_return nil
    @search.stub!(:faqs).and_return nil
    @search.stub!(:gov_forms).and_return nil
    @search.stub!(:spotlight).and_return nil
    @search.stub!(:error_message).and_return "Ignore me"
    @search.stub!(:filter_setting).and_return nil
    @search.stub!(:scope_id).and_return nil
    @search.stub!(:fedstates).and_return nil
    @search.stub!(:agency).and_return nil
    assigns[:search] = @search
  end
  
  it "should link to the medium sized search logo" do
    render
    response.body.should have_tag("img[src^=/images/USAsearch_medium_en.gif]")
  end
  
  context "when rendered as a forms serp" do
    before do
      controller.action_name = "forms"
      render
    end
    
    it "should link to the medium sized forms search logo" do
      response.body.should have_tag("img[src^=/images/USAsearch_medium_en_forms.gif]")
    end
  end
  
  context "when spelling suggestion is available" do
    before do
      @rong = "U mispeled everytheeng"
      @rite = "You misspelled everything"
      @search.stub!(:query).and_return @rong
      @search.stub!(:spelling_suggestion).and_return @rite
    end

    it "should show the spelling suggestion" do
      render
      response.should contain("We're including results for #{@rite}. Do you want results only for #{@rong}?")
    end
  end

  context "when there is a blank search" do
    before do
      @search.stub!(:query).and_return ""
      @search.stub!(:spelling_suggestion).and_return nil
      @search.stub!(:results).and_return []
      @search.stub!(:boosted_contents).and_return nil
      @search.stub!(:faqs).and_return nil
      @search.stub!(:gov_forms).and_return nil
      @search.stub!(:spotlight).and_return nil
      @search.stub!(:error_message).and_return "Enter some search terms"
      @search.stub!(:filter_setting).and_return nil
      @search.stub!(:scope_id).and_return nil
      @search.stub!(:fedstates).and_return nil
    end

    it "should show header search form but not show footer search form" do
      render
      response.should contain("Enter some search terms")
      response.should have_selector("#search_query")
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
      @search.stub!(:boosted_contents).and_return nil
      @search.stub!(:faqs).and_return nil
      @search.stub!(:gov_forms).and_return nil
      @search.stub!(:filter_setting).and_return nil
      @search.stub!(:scope_id).and_return nil
      @search.stub!(:fedstates).and_return nil
    end

    context "when there are fewer than five results" do
      before do
        4.times { @search_results << @search_result }
      end

      it "should show header search form but not show footer search form" do
        render
        response.should have_selector("#search_query")
        response.should_not have_selector("#footer_search_form")
      end
    end

    context "when there are five results" do
      before do
        5.times { @search_results << @search_result }
      end

      it "should show header search form and footer search form" do
        render
        response.should have_selector("#search_query")
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

    context "when a fedstates filter is set from the advanced form" do
      before do
        @search.stub!(:fedstates).and_return 'MD'
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
          @search.stub!(:fedstates).and_return 'all'
        end

        it "should not show a restriction message" do
          render
          response.should_not contain(/This search was restricted/)
        end
      end
    end

    context "when results have potential XSS attack code" do
      before do
        @dangerous_url = "http://www.first.army.mil/family/contentdisplayFAFP.asp?ContentID=133&SiteID=\"><script>alert(String.fromCharCode(88,83,83))</script>"
        @sanitized_url = "http://www.first.army.mil/family/contentdisplayFAFP.asp?ContentID=133&SiteID=\"><script>alert(String.fromCharCode(88,83,83))</script>"
        @dangerous_title = "Dangerous Title"
        @dangerous_content = "Dangerous Content"
        @search_result = {'title' => @dangerous_title,
                         'unescapedUrl'=> @dangerous_url,
                         'content'=> @dangerous_content,
                         'cacheUrl'=> @dangerous_url
        }
        @search_results = []
        @search_results.stub!(:total_pages).and_return 1
        @search.stub!(:results).and_return @search_results
        @search_results << @search_result
      end

      it "should escape the url" do
        render
        response.should_not contain(/onmousedown/)
      end
    end
    
    context "when an agency record matches the query" do
      before do
        Agency.destroy_all
        @agency = Agency.create!(:name => 'Internal Revenue Service', :domain => 'irs.gov', :phone => '888-555-1040', :url => 'http://www.irs.gov/', :twitter_username => 'IRSnews', :es_url => 'http://www.irs.gov/es/')
        @agency_query = AgencyQuery.create!(:phrase => 'irs', :agency => @agency)
        @search.stub!(:query).and_return "irs"
        @search_result = {'title' => "Internal Revenue Service",
                          'unescapedUrl'=> "http://www.irs.gov/",
                          'content'=> "The official page of the Internal Revenue Service",
                          'cacheUrl'=> "http://www.cached.com/url"}
        @search_results = [@search_result]
        @search_results.stub!(:total_pages).and_return 1
        @search.stub!(:results).and_return @search_results
        @search.stub!(:agency).and_return @agency
      end
      
      context "if the first result matches the URL in the agency query" do
        it "should format the first result as a special agency result" do
          render
          response.should have_tag("div[class=govbox]")
          response.should contain(/www.irs.gov\/ | Official Site/)
          response.should_not contain(/www.irs.gov\/ - Cached/)
          response.should contain(/Contact: 888-555-1040/)
          response.should_not contain(/Toll-free:/)
          response.should_not contain(/TTY:/)
          response.should contain(/Search within irs.gov/)
          response.should contain(/Twitter:/)
          response.should have_tag "form[action=/search]" do
            with_tag "input[type=hidden][name=sitelimit][value=irs.gov]"
            with_tag "input[type=hidden][name=locale][value=en]"
            with_tag "input[type=submit][value=Search]"
          end
          response.should have_tag("a[href=#{@agency.twitter_profile_link}]", :text => @agency.twitter_profile_link)
          response.should_not have_tag("a[href=#{@agency.facebook_profile_link}]", :text => @agency.twitter_profile_link)
        end
      end
      
      context "when the page specified is greater than 0 (i.e. we're not on the first page)" do
        before do
          @search.stub!(:page).and_return 1
        end
        
        it "should not render a special agency result, even if the first result matches" do
          render
          response.should_not have_tag "div[class=govbox]"
          response.should_not contain(/Contact: 888-555-1040/)
          response.should_not contain(/Search within irs.gov/)
          response.should_not have_tag "form[action=/search]" do
            with_tag "input[type=hidden][name=sitelimit][value=irs.gov]"
          end
        end
      end
      
      context "when the locale is set to Spanish" do
        before do
          I18n.locale = :es
        end
        
        context "when the Spanish URL does not match the result url (and when the English URL does)" do
          it "should not render a special agency result, even if the first result matches the English URL" do
            render
            response.should_not have_tag "div[class=govbox]"
            response.should_not contain(/Contact: 888-555-1040/)
            response.should_not contain(/Search within irs.gov/)
            response.should_not have_tag "form[action=/search]" do
              with_tag "input[type=hidden][name=sitelimit][value=irs.gov]"
            end
          end
        end
        
        context "when the Spanish URL matches the result url" do
          before do
            @search_result = {'title' => "Internal Revenue Service - Spanish",
                          'unescapedUrl'=> "http://www.irs.gov/es/",
                          'content'=> "The official page of the Internal Revenue Service",
                          'cacheUrl'=> "http://www.cached.com/url"}
            @search_results = [@search_result]
            @search_results.stub!(:total_pages).and_return 1
            @search.stub!(:results).and_return @search_results
          end
          
          it "should render the first result as a Spanish agency govbox" do
            render
            response.should have_tag "div[class=govbox]"
            response.should contain(/Contacto: 888-555-1040/)
            response.should contain(/Buscar en irs.gov/)
            response.should contain(/Twitter \(en inglés\)/)
            response.should have_tag "form[action=/search]" do
              with_tag "input[type=hidden][name=sitelimit][value=irs.gov]"
              with_tag "input[type=hidden][name=locale][value=es]"
              with_tag "input[type=submit][value=Buscar]"
            end
          end
        end
        
        after do
          I18n.locale = I18n.default_locale
        end
      end  
      
      context "when the matching result is not the first result" do
        before do
          dummy_result = {'title' => "External Revenue Service",
                          'unescapedUrl'=> "http://www.ers.gov/",
                          'content'=> "The official page of the External Revenue Service",
                          'cacheUrl'=> "http://www.cached.com/url"}
          @search_results = [dummy_result, @search_result]
          @search_results.stub!(:total_pages).and_return 1
          @search.stub!(:results).and_return @search_results        
        end
        
        it "should not render a special agency result, even if the first result matches" do
          render
          response.should_not have_tag "div[class=govbox]"
          response.should_not contain(/Contact: 888-555-1040/)
          response.should_not contain(/Search within irs.gov/)
          response.should_not have_tag "form[action=/search]" do
            with_tag "input[type=hidden][name=sitelimit][value=irs.gov]"
          end
        end
      end         
    end
  end
end
