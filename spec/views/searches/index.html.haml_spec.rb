# coding: utf-8
require 'spec_helper'


describe "searches/index.html.haml" do
  fixtures :affiliates, :image_search_labels, :navigations
  before do
    @affiliate = affiliates(:usagov_affiliate)
    assign(:affiliate, @affiliate)

    @search = stub("WebSearch", has_photos?: false, med_topic: nil, jobs: nil,
                   has_boosted_contents?: false, has_related_searches?: false,
                   has_featured_collections?: false, has_video_news_items?: false,
                   has_news_items?: false, agency: nil, tweets: nil, query: "test", affiliate: @affiliate,
                   page: 1, spelling_suggestion: nil, queried_at_seconds: 1271978870, results: [],
                   error_message: "Ignore me", scope_id: nil, first_page?: true, matching_site_limits: [],
                   module_tag: 'BWEB', tracking_information: 'Ref A: whatever')
    assign(:search, @search)
    assign(:search_params, {affiliate: @affiliate.name, query: 'test'})
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
      @search.stub!(:error_message).and_return "Enter some search terms"
    end

    it "should show header search form" do
      render
      rendered.should contain("Enter some search terms")
      rendered.should have_selector("#search_query")
    end
  end

  context "when there are search results" do
    before do
      @search.stub!(:startrecord).and_return 1
      @search.stub!(:endrecord).and_return 10
      @search.stub!(:total).and_return 2000
      @search.stub!(:page).and_return 1
      @search_result = {'title' => "some title",
                        'unescapedUrl' => "http://www.foo.com/url",
                        'content' => "This is a sample result",
                        'cacheUrl' => "http://www.cached.com/url"
      }
      @search_results = []
      @search_results.stub!(:total_pages).and_return 1
      @search.stub!(:results).and_return @search_results
    end

    context "when results have potential XSS attack code" do
      before do
        @dangerous_url = "http://www.first.army.mil/family/contentdisplayFAFP.asp?ContentID=133&SiteID=\"><script>alert(String.fromCharCode(88,83,83))</script>"
        @sanitized_url = "http://www.first.army.mil/family/contentdisplayFAFP.asp?ContentID=133&SiteID=\"><script>alert(String.fromCharCode(88,83,83))</script>"
        @dangerous_title = "Dangerous Title"
        @dangerous_content = "Dangerous Content"
        @search_result = {'title' => @dangerous_title,
                          'unescapedUrl' => @dangerous_url,
                          'content' => @dangerous_content,
                          'cacheUrl' => @dangerous_url
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
                          'unescapedUrl' => @pdf_url,
                          'content' => "Bob is really good",
                          'cacheUrl' => @pdf_url
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
                          'unescapedUrl' => @non_pdf_url,
                          'content' => "Bob is really good",
                          'cacheUrl' => @non_pdf_url
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

    context "when federal jobs results are available" do
      before do
        @affiliate.stub!(:jobs_enabled?).and_return(true)
        json = [
          {"id" => "usajobs:328437200", "position_title" => "<em>Research</em> Biologist/<em>Research</em> Nutritionist (Postdoctoral <em>Research</em> Affiliate)",
           "organization_name" => "Agricultural Research Service", "rate_interval_code" => "PA", "minimum" => 51871, "maximum" => 67427, "start_date" => "2012-10-10", "end_date" => "2023-10-12", "locations" => ["Boston, MA"],
           "url" => "https://www.usajobs.gov/GetJob/ViewDetails/328437200"},
          {"id" => "usajobs:328437201", "position_title" => "Some Research Job",
           "organization_name" => "Some Research Service", "rate_interval_code" => "PH", "minimum" => 24, "maximum" => 24, "start_date" => "2012-10-10", "end_date" => "2023-10-13", "locations" => ["Boston, MA", "Cohasset, MA"],
           "url" => "https://www.usajobs.gov/GetJob/ViewDetails/328437201"},
          {"id" => "usajobs:328437202", "position_title" => "Bi-Weekly Research Job",
           "organization_name" => "BW Research Service", "rate_interval_code" => "BW", "minimum" => 240, "maximum" => 260, "start_date" => "2012-10-10", "end_date" => "2023-10-15", "locations" => ["Hello, MA"],
           "url" => "https://www.usajobs.gov/GetJob/ViewDetails/328437202"},
          {"id" => "usajobs:328437203", "position_title" => "Zero Money Research Job",
           "organization_name" => "Some Poor Research Service", "rate_interval_code" => "WC", "minimum" => 0, "maximum" => 0, "start_date" => "2012-10-10", "end_date" => "2023-10-14", "locations" => ["Washington Metro Area, DC"],
           "url" => "https://www.usajobs.gov/GetJob/ViewDetails/328437203"}
        ]
        mashies = json.collect { |x| Hashie::Mash.new(x) }
        @search.stub!(:query).and_return "research jobs"
        @search_result = {'title' => "This is about research jobs",
                          'unescapedUrl' => "http://www.cdc.gov/jobs",
                          'content' => "Research jobs don't pay well",
                          'cacheUrl' => "http://www.cached.com/url"}
        @search_results = [@search_result]
        @search_results.stub!(:total_pages).and_return 1
        @search.stub!(:results).and_return @search_results
        @search.stub!(:jobs).and_return mashies
      end

      it "should show them in a govbox" do
        render
        rendered.should contain("Federal Job Openings")
        rendered.should have_selector(:a,
                                      content: 'Research Biologist/Research Nutritionist (Postdoctoral Research Affiliate)',
                                      href: 'https://www.usajobs.gov/GetJob/ViewDetails/328437200?PostingChannelID=USASearch')
        rendered.should contain("Agricultural Research Service")
        rendered.should contain("Boston, MA \u00A0\u00A0\u2022\u00A0\u00A0 $51,871.00+/yr")
        rendered.should contain("Apply by October 12, 2023")

        rendered.should have_selector(:a,
                                      content: 'Some Research Job',
                                      href: 'https://www.usajobs.gov/GetJob/ViewDetails/328437201?PostingChannelID=USASearch')
        rendered.should contain("Some Research Service")
        rendered.should contain("Multiple Locations \u00A0\u00A0\u2022\u00A0\u00A0 $24.00/hr")
        rendered.should contain("Apply by October 13, 2023")

        rendered.should have_selector(:a,
                                      content: 'Bi-Weekly Research Job',
                                      href: 'https://www.usajobs.gov/GetJob/ViewDetails/328437202?PostingChannelID=USASearch')
        rendered.should contain("BW Research Service")
        rendered.should contain("Hello, MA")
        rendered.should contain("Apply by October 15, 2023")

        rendered.should_not contain('Zero Money Research Job')

        rendered.should have_selector(:a,
                                      content: 'See all federal job openings',
                                      href: 'https://www.usajobs.gov/JobSearch/Search/GetResults?PostingChannelID=USASearch')
      end

      context 'when affiliate locale is es' do
        before { I18n.locale = :es }
        after { I18n.locale = I18n.default_locale }

        it 'should show links with Spanish translations' do
          render
          rendered.should have_selector(:a,
                                        content: 'Vea todos los trabajos en el Gobierno',
                                        href: 'https://www.usajobs.gov/JobSearch/Search/GetResults?PostingChannelID=USASearch')
        end
      end

      context 'when there is an agency associated with the affiliate' do
        before do
          agency = Agency.create!({:name => 'Some New Agency',
                                   :domain => 'SNA.gov',
                                   :abbreviation => 'SNA',
                                   :organization_code => 'XX00',
                                   :name_variants => 'Some Service'})
          @affiliate.stub!(:agency).and_return(agency)
        end

        it "should show the agency-specific info without agency name" do
          render
          rendered.should contain("Job Openings at SNA")
          rendered.should contain("See all SNA job openings")
          rendered.should_not contain("Agricultural Research Service")
          rendered.should_not contain("Some Research Service")
          rendered.should_not contain("BW Research Service")
          rendered.should_not contain("Some Poor Research Service")
        end

        context 'when the affiliate locale is es' do
          before do
            I18n.locale = :es
          end

          it 'should localize the header' do
            render
            rendered.should contain(" Trabajos en SNA (en inglés)")
          end

          after do
            I18n.locale = I18n.default_locale
          end

        end
      end

      context 'when there is a department associated with the affiliate' do
        before do
          dept = Agency.create!({:name => 'Some New Dept',
                                 :domain => 'DOS.gov',
                                 :abbreviation => 'DOS',
                                 :organization_code => 'DS',
                                 :name_variants => 'Service Dept'})
          @affiliate.stub!(:agency).and_return(dept)
        end

        it "should show the agency-specific info" do
          render
          rendered.should contain("Job Openings at DOS")
          rendered.should contain("See all DOS job openings")
          rendered.should contain("Agricultural Research Service")
          rendered.should contain("Some Research Service")
          rendered.should contain("BW Research Service")
          rendered.should_not contain("Some Poor Research Service")
        end
      end

    end

    context 'when neogov jobs results are available' do
      before do
        @affiliate.stub!(:jobs_enabled?).and_return(true)
        json = [
            {"id" => "ng:michigan:328437200", "position_title" => "<em>Research</em> Biologist/<em>Research</em> Nutritionist (Postdoctoral <em>Research</em> Affiliate)",
             "organization_name" => "Agricultural Research Service", "rate_interval_code" => "PA", "minimum" => 51871, "maximum" => 67427, "start_date" => "2012-10-10", "end_date" => "2023-10-12", "locations" => ["Boston, MA"],
             "url" => "http://agency.governmentjobs.com/michigan/default.cfm?action=viewjob&jobid=328437200"}]
        mashies = json.collect { |x| Hashie::Mash.new(x) }
        @search.stub!(:query).and_return "research jobs"
        @search_result = {'title' => "This is about research jobs",
                          'unescapedUrl' => "http://www.cdc.gov/jobs",
                          'content' => "Research jobs don't pay well",
                          'cacheUrl' => "http://www.cached.com/url"}
        @search_results = [@search_result]
        @search_results.stub!(:total_pages).and_return 1
        @search.stub!(:results).and_return @search_results
        @search.stub!(:jobs).and_return mashies
      end

      context 'when there is  agency associated with the affiliate' do
        before do
          agency = Agency.create!({:name => 'State of Michigan',
                                   :domain => 'michigan.gov',
                                   :abbreviation => 'SOM',
                                   :organization_code => 'USMI',
                                   :name_variants => 'Some Service'})
          @affiliate.stub!(:agency).and_return(agency)
        end

        it "should show the neogov links" do
          render
          rendered.should contain('Job Openings at SOM')
          rendered.should have_selector(:a,
                                        content: 'Research Biologist/Research Nutritionist (Postdoctoral Research Affiliate)',
                                        href: 'http://agency.governmentjobs.com/michigan/default.cfm?action=viewjob&jobid=328437200')
          rendered.should have_selector(:a,
                                        content: 'See all SOM job openings',
                                        href: 'http://agency.governmentjobs.com/michigan/default.cfm')
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
                                 'cacheUrl' => "http://www.cached.com/url"}
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
          related_topic = med_topics(:crohns_disease)
          @med_topic.med_related_topics.create!(:related_medline_tid => related_topic.medline_tid,
                                                :title => related_topic.medline_title,
                                                :url => related_topic.medline_url)
        end

        it "should include the related topics in the result, with links to search results pages" do
          render
          rendered.should contain(/Related MedlinePlus Topics/)
          rendered.should have_selector "a", :href => "http://www.nlm.nih.gov/medlineplus/crohnsdisease.html", :content => 'Crohn\'s Disease'
        end
      end

      context "when the MedTopic has sites" do
        before do
          @med_topic.med_sites.create!(:title => 'Crohn\'s Disease',
                                       :url => 'http://clinicaltrials.gov/search/open/condition=%22Crohn+Disease%22')
          @med_topic.med_sites.create!(:title => 'Inflammatory Bowel Diseases',
                                       :url => 'http://clinicaltrials.gov/search/open/condition=%22Inflammatory+Bowel+Diseases%22')
          @med_topic.med_sites.create!(:title => 'Ulcerative Colitis',
                                       :url => 'http://clinicaltrials.gov/search/open/condition=%22Ulcerative+Colitis%22')
        end

        it "should include links to the first two linked to clinicaltrials.gov" do
          render
          rendered.should contain(/ClinicalTrials.gov/)
          rendered.should have_selector :a, :href => 'http://clinicaltrials.gov/search/open/condition=%22Crohn+Disease%22'
          rendered.should have_selector :a, :href => 'http://clinicaltrials.gov/search/open/condition=%22Inflammatory+Bowel+Diseases%22'
          rendered.should_not have_selector :a, :href => 'http://clinicaltrials.gov/search/open/condition=%22Ulcerative+Colitis%22'
        end
      end
    end
  end
end
