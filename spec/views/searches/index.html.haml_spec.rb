require 'spec/spec_helper'
describe "searches/index.html.haml" do
  fixtures :affiliates, :image_search_labels, :navigations
  before do
    @affiliate = affiliates(:usagov_affiliate)
    assign(:affiliate, @affiliate)

    @search = stub("WebSearch")
    @search.stub!(:query).and_return "test"
    @search.stub!(:affiliate).and_return @affiliate
    @search.stub!(:page).and_return 1
    @search.stub!(:spelling_suggestion).and_return nil
    @search.stub!(:related_search).and_return []
    @search.stub!(:has_related_searches?).and_return false
    @search.stub!(:queried_at_seconds).and_return(1271978870)
    @search.stub!(:news_items)
    @search.stub!(:video_news_items)
    @search.stub!(:recalls)
    @search.stub!(:extra_image_results)
    @search.stub!(:results).and_return []
    @search.stub!(:has_boosted_contents?).and_return false
    @search.stub!(:gov_forms).and_return nil
    @search.stub!(:error_message).and_return "Ignore me"
    @search.stub!(:filter_setting).and_return nil
    @search.stub!(:scope_id).and_return nil
    @search.stub!(:agency).and_return nil
    @search.stub!(:med_topic).and_return nil
    @search.stub!(:has_featured_collections?).and_return false
    @search.stub!(:are_results_by_bing?).and_return true
    @search.stub!(:first_page?).and_return true
    @search.stub!(:matching_site_limits).and_return []
    @search.stub!(:indexed_documents).and_return nil
    assign(:search, @search)
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
      @search.stub!(:error_message).and_return "Enter some search terms"
      @search.stub!(:filter_setting).and_return nil
      @search.stub!(:scope_id).and_return nil
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
      @search.stub!(:page).and_return 1
      @search_result = {'title' => "some title",
                        'unescapedUrl'=> "http://www.foo.com/url",
                        'content'=> "This is a sample result",
                        'cacheUrl'=> "http://www.cached.com/url"
      }
      @search_results = []
      @search_results.stub!(:total_pages).and_return 1
      @search.stub!(:results).and_return @search_results
      @search.stub!(:boosted_contents).and_return nil
      @search.stub!(:faqs).and_return nil
      @search.stub!(:gov_forms).and_return nil
      @search.stub!(:filter_setting).and_return nil
      @search.stub!(:scope_id).and_return nil
    end

    it "should not display a hidden filter parameter" do
      render
      rendered.should_not have_selector("input[type='hidden'][name='filter']")
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
        @agency.agency_popular_urls.create!( :url => 'http://www.irs.gov/forms/1040.pdf', :title => "Form 1040", :rank => 1, :locale => 'en')
        @agency.agency_popular_urls.create!( :url => 'http://www.irs.gov/forms/1040nr.pdf', :title => "Form 1040-NR", :rank => 2, :locale => 'en')
        @agency.agency_popular_urls.create!( :url => 'http://www.irs.gov/pub/irs-pdf/f1040.pdf', :title => "Formulario 1040 U.S. Individual Income Tax Return", :rank => 2, :locale => 'es')
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
          rendered.should have_selector "div[class='govbox agency']"
          rendered.should contain("www.irs.gov")
          rendered.should contain(/888-555-1040 \(Contact\)/)
          rendered.should_not contain(/Toll-free:/)
          rendered.should_not contain(/TTY:/)
          rendered.should contain(/Search within irs.gov/)
          rendered.should contain(/Twitter/)
          rendered.should have_selector "form[action='/search']"
          rendered.should have_selector "input[type='hidden'][name='sitelimit'][value='irs.gov']"
          rendered.should have_selector "input[type='hidden'][name='locale'][value='en']"
          rendered.should have_selector "input[type='submit'][value='Search']"
          rendered.should have_selector("a", :href => @agency.twitter_profile_link, :content => "Twitter")
          rendered.should_not contain("Facebook:")
          rendered.should have_selector("div[class='popular-pages']")
          rendered.should contain(/Form 1040-NR/)
          rendered.should_not contain(/Páginas populares/)
          rendered.should contain(/Popular Pages/)
        end

        context "when there are no phone numbers" do
          before do
            @agency.phone = nil
          end

          it "should not show a phone icon or div" do
            render
            rendered.should_not have_selector "div[class='phone-wrapper']"
            rendered.should_not have_selector "img[src^='/images/govbox/phone.gif']"
          end

          after do
            @agency.reload
          end
        end
      end

      context "when the page specified is greater than 0 (i.e. we're not on the first page)" do
        before do
          @search.stub!(:page).and_return 2
          @search.stub!(:first_page?).and_return false
        end

        it "should not render a special agency result, even if the first result matches" do
          render
          rendered.should_not have_selector "div[class='govbox agency']"
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
            rendered.should have_selector "div[class='govbox agency']"
            rendered.should contain(/888-555-1040 \(Contacto\)/)
            rendered.should contain(/Buscar en irs.gov/)
            rendered.should contain(/Twitter \(en inglés\)/)
            rendered.should have_selector "form[action='/search']"
            rendered.should have_selector "input[type='hidden'][name='sitelimit'][value='irs.gov']"
            rendered.should have_selector "input[type='hidden'][name='locale'][value='es']"
            rendered.should have_selector "input[type='submit'][value='Buscar']"
            rendered.should have_selector("div[class='popular-pages']")
            rendered.should contain("Formulario 1040 U.S. Individual Income Tax Return")
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

      context "when there are popular urls with identical titles" do
        before do
          @agency.agency_popular_urls.create!(:url => 'http://some.link', :title => 'Form 1040', :rank => 3, :locale => 'en')
        end

        it "should modify the duplicate titles to include numbers" do
          render
          rendered.should have_selector "a[href='http://some.link']", :content => 'Form 1040 (1)'
          rendered.should have_selector "a[href='http://www.irs.gov/forms/1040.pdf']", :content => 'Form 1040 (2)'
        end
      end

      context "when a title is longer than 50 characters" do
        before do
          @agency.agency_popular_urls.create!(:url => 'http://some.link', :title => 'This is a really long title that we are going to truncate so it is not so long.', :rank => 5, :locale => 'en')
        end

        it "should truncate the title" do
          render
          rendered.should contain(/This is a really long title that we are going\.\.\./)
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
        another_search_result = {'title' => "Ulcerative Colitis",
                                 'unescapedUrl' => "http://ulcerativecolitis.gov",
                                 'content' => "I have ulcerative colitis.",
                                 'cacheUrl' => "http://www.cached.com/url" }
        @search_results = [another_search_result, @search_result]
        @search_results.stub!(:total_pages).and_return 1
        @search.stub!(:results).and_return @search_results
        @search.stub!(:med_topic).and_return @med_topic
      end

      it "should format the result as a Medline Govbox" do
        render
        rendered.should contain(/Official result from MedlinePlus/)
        rendered.should contain(/Ulcerative colitis/)
        rendered.should contain(/Ulcerative colitis is a disease that causes/)
        rendered.should contain(/Ulcerative colitis can happen at any age, but.../)

        rendered.should_not contain(/Related MedlinePlus Topics/)
        rendered.should_not contain(/Esta tema en español/)
        rendered.should_not contain(/ClinicalTrials.gov/)
      end

      it "should not display a regular result with the same Medline URL/information" do
        render
        rendered.should_not =~ /Ulcerative colitis is a disease.*Ulcerative colitis is a disease/
      end

      context "when the MedTopic has related med topics" do
        before do
          @med_topic.related_topics << med_topics(:crohns_disease)
        end

        it "should include the related topics in the result, with links to search results pages" do
          render
          rendered.should contain(/Related MedlinePlus Topics/)
          rendered.should have_selector "a", :href => "/search?affiliate=usagov&locale=en&query=Crohn%27s+Disease", :content => 'Crohn\'s Disease'
        end
      end

      context "when the MedTopic has mesh titles" do
        before do
          @med_topic.mesh_titles = "Ulcerative Colitis:Crohn's Disease:Irritable Bowel Syndrome"
        end

        it "should include links to the first two linked to clinicaltrials.gov" do
          render
          rendered.should contain(/ClinicalTrials.gov/)
          rendered.should have_selector "a", :href => "http://clinicaltrials.gov/search/open/condition=#{URI.escape("\"" + h("Ulcerative Colitis") + "\"")}"
          rendered.should have_selector "a", :href => "http://clinicaltrials.gov/search/open/condition=#{URI.escape("\"" + h("Crohn's Disease") + "\"")}"
          rendered.should_not have_selector "a", :href => "http://clinicaltrials.gov/search/open/condition=#{URI.escape("\"" + h("Irritable Bowel Syndrome") + "\"")}"
        end
      end
    end
  end
end
