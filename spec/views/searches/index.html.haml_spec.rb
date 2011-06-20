require 'spec/spec_helper'
describe "searches/index.html.haml" do
  before do
    @search = stub("Search")
    @search.stub!(:query).and_return "test"
    @search.stub!(:page).and_return 0
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
    @search.stub!(:med_topic).and_return nil
    assign(:search, @search)
  end

  it "should link to the medium sized search logo" do
    render
    rendered.should have_selector("img[src^='/images/USAsearch_medium_en.gif']")
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
      rendered.should contain("We're including results for #{@rite}. Do you want results only for #{@rong}?")
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

    it "should show header search form" do
      render
      rendered.should contain("Enter some search terms")
      rendered.should have_selector("#search_query")
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

    it "should not display a hidden filter parameter" do
      render
      rendered.should_not have_selector("input[type='hidden'][name='filter']")
    end

    it "should not display a hidden fedstates parameter" do
      render
      rendered.should_not have_selector("input[type='hidden'][name='fedstates']")
    end

    context "when a filter parameter is specified" do
      before do
        @filter_setting = "moderate"
        @search.stub!(:filter_setting).and_return @filter_setting
      end

      it "should include a hidden input field in the search form with the filter parameter" do
        render
        rendered.should have_selector("input[type='hidden'][name='filter'][value='#{@filter_setting}']")
      end
    end

    context "when a fedstates filter is set from the advanced form" do
      before do
        @search.stub!(:fedstates).and_return 'MD'
      end

      it "should include a hidden input field in the search with the fedstates value set to the scope id" do
        render
        rendered.should have_selector("input[type='hidden'][name='fedstates'][value='MD']")
      end

      it "should inform the user that the search was restricted" do
        5.times { @search_results << @search_result }
        render
        rendered.should contain(/This search was restricted/)
      end

      it "should link to a unrestricted version of the search" do
        render
        rendered.should_not have_selector("a[href~='fedstates=MD']")
      end

      context "when the scope id is set to 'all'" do
        before do
          @search.stub!(:fedstates).and_return 'all'
        end

        it "should not show a restriction message" do
          render
          rendered.should_not contain(/This search was restricted/)
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
        rendered.should_not contain(/onmousedown/)
      end
    end

    context "when results link to a PDF" do
      before do
        @pdf_url = "http://www.army.mil/~bob/resume.pdf"
        @search_result = {'title' => "Bob's resume",
                          'unescapedUrl'=> @pdf_url,
                          'content'=> "Bob is really good",
                          'cacheUrl'=> @pdf_url
        }
        @search_results = []
        @search_results.stub!(:total_pages).and_return 1
        @search.stub!(:results).and_return @search_results
        @search_results << @search_result
      end

      it "should insert a [PDF] before the link" do
        render
        rendered.should have_selector("span[class='uext_type']")
      end
    end

    context "when results link to something not a PDF" do
      before do
        @non_pdf_url = "http://www.army.mil/~bob/resume/"
        @search_result = {'title' => "Bob's resume",
                          'unescapedUrl'=> @non_pdf_url,
                          'content'=> "Bob is really good",
                          'cacheUrl'=> @non_pdf_url
        }
        @search_results = []
        @search_results.stub!(:total_pages).and_return 1
        @search.stub!(:results).and_return @search_results
        @search_results << @search_result
      end

      it "should insert a [PDF] before the link" do
        render
        rendered.should_not have_selector("span[class='uext_type']")
      end
    end

    context "when an agency record matches the query" do
      before do
        Agency.destroy_all
        @agency = Agency.create!(:name => 'Internal Revenue Service', :domain => 'irs.gov', :phone => '888-555-1040', :twitter_username => 'IRSnews')
        @agency.agency_urls << AgencyUrl.new(:url => 'http://www.irs.gov/', :locale => 'en')
        @agency.agency_urls << AgencyUrl.new(:url => 'http://www.irs.gov/es/', :locale => 'es')
        @agency.agency_popular_urls << AgencyPopularUrl.new( :url => 'http://www.irs.gov/forms/1040.pdf', :title => "Form 1040", :rank => 1)
        @agency.agency_popular_urls << AgencyPopularUrl.new( :url => 'http://www.irs.gov/forms/1040nr.pdf', :title => "Form 1040-NR", :rank => 2)
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
          rendered.should have_selector("div[class='govbox']")
          rendered.should contain("| Official Site")
          rendered.should_not contain(/www.irs.gov\/ - Cached/)
          rendered.should contain(/Contact: 888-555-1040/)
          rendered.should_not contain(/Toll-free:/)
          rendered.should_not contain(/TTY:/)
          rendered.should contain(/Search within irs.gov/)
          rendered.should contain(/Twitter:/)
          rendered.should have_selector "form[action='/search']"
          rendered.should have_selector "input[type='hidden'][name='sitelimit'][value='irs.gov']"
          rendered.should have_selector "input[type='hidden'][name='locale'][value='en']"
          rendered.should have_selector "input[type='submit'][value='Search']"
          rendered.should have_selector("a", :href => @agency.twitter_profile_link, :target => "_blank", :content => @agency.twitter_profile_link)
          rendered.should_not contain("Facebook:")
          rendered.should have_selector("div[class='popular']")
          rendered.should contain(/Form 1040-NR/)
          rendered.should_not contain(/Páginas populares/)
          rendered.should contain(/Popular Pages/)
        end
      end

      context "when the page specified is greater than 0 (i.e. we're not on the first page)" do
        before do
          @search.stub!(:page).and_return 1
        end

        it "should not render a special agency result, even if the first result matches" do
          render
          rendered.should_not have_selector "div[class=govbox]"
          rendered.should_not contain(/Contact: 888-555-1040/)
          rendered.should_not contain(/Search within irs.gov/)
          rendered.should have_selector "form[action='/search']"
          rendered.should_not have_selector "input[type='hidden'][name='sitelimit'][value='irs.gov']"
          rendered.should_not have_selector("div[class='popular']")
          rendered.should_not contain(/Popular Pages/)
        end
      end

      context "when the locale is set to Spanish" do
        before do
          I18n.locale = :es
        end

        context "when the Spanish URL does not match the result url (and when the English URL does)" do
          it "should not render a special agency result, even if the first result matches the English URL" do
            render
            rendered.should_not have_selector "div[class=govbox]"
            rendered.should_not contain(/Contact: 888-555-1040/)
            rendered.should_not contain(/Search within irs.gov/)
            rendered.should have_selector "form[action='/search']"
            rendered.should_not have_selector "input[type='hidden'][name='sitelimit'][value='irs.gov']"
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
            rendered.should have_selector "div[class=govbox]"
            rendered.should contain(/Contacto: 888-555-1040/)
            rendered.should contain(/Buscar en irs.gov/)
            rendered.should contain(/Twitter \(en inglés\)/)
            rendered.should have_selector "form[action='/search']"
            rendered.should have_selector "input[type='hidden'][name='sitelimit'][value='irs.gov']"
            rendered.should have_selector "input[type='hidden'][name='locale'][value='es']"
            rendered.should have_selector "input[type='submit'][value='Buscar']"
            rendered.should have_selector("div[class='popular']")
            rendered.should contain(/Form 1040-NR/)
            rendered.should contain(/Páginas populares/)
            rendered.should_not contain(/Popular Pages/)
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
          rendered.should_not have_selector "div[class='govbox']"
          rendered.should_not contain(/Contact: 888-555-1040/)
          rendered.should_not contain(/Search within irs.gov/)
          rendered.should have_selector "form[action='/search']"
          rendered.should_not have_selector("input[type='hidden'][name='sitelimit'][value='irs.gov']")
        end
      end
    end
  
    context "when a med topic record matches the query" do
      fixtures :med_topics
      before do
        @med_topic = med_topics(:ulcerative_colitis)
        @search.stub!(:query).and_return "ulcerative colitis"
        @search_result = {'title' => "Ulcerative Colitis",
                          'unescapedUrl' => "http://www.nlm.nih.gov/medlineplus/ulcerativecolitis.html",
                          'content' => "I have ulcerative colitis.",
                          'cacheUrl' => "http://www.cached.com/url"}
        @search_results = [@search_result]
        @search_results.stub!(:total_pages).and_return 1
        @search.stub!(:results).and_return @search_results
        @search.stub!(:med_topic).and_return @med_topic
      end
      
      it "should format the result as a Medline Govbox" do
        render
        rendered.should contain(/Official result from MedlinePlus/)
        rendered.should have_selector "img[src^='/images/medline.en.png']"
        rendered.should contain(/Ulcerative colitis/)
        rendered.should contain(/Ulcerative colitis is a disease that causes/)
        rendered.should contain(/Ulcerative colitis can happen at any age, but.../)
      end
      
      context "when the MedTopic has related med topics" do
        before do
          @med_topic.related_topics << med_topics(:crohns_disease)
        end
        
        it "should include the related topics in the result, with links to search results pages" do
          render
          rendered.should contain(/Related MedlinePlus Topics/)
          rendered.should have_selector "a", :href => "/search?locale=en&query=Crohn%27s+Disease", :content => 'Crohn\'s Disease'
        end
      end
      
      context "when the MedTopic has an alternate language version" do
        before do
          @med_topic.lang_mapped_topic = med_topics(:ulcerative_colitis_es)
        end
        
        it "should include a link to the other language version" do
          render
          rendered.should contain(/Esta tema en español/)
          rendered.should have_selector "a", :href => "/search?locale=es&query=Colitis+ulcerativa", :content => 'Colitis ulcerativa'
        end
      end
    end
  end
end
