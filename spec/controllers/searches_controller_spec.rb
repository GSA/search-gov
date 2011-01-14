require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchesController do
  fixtures :affiliates, :affiliate_templates

  describe "#auto_complete_for_search_query" do
    it "should use query param to find terms starting with that param" do
      SaytSuggestion.create(:phrase=>"Lorem ipsum dolor sit amet")
      get :auto_complete_for_search_query, :query=>"lorem"
      response.body.should match(/lorem/i)
    end

    it "should not completely melt down when strange characters are present" do
      lambda {get :auto_complete_for_search_query, :query=>"foo\\"}.should_not raise_error
      lambda {get :auto_complete_for_search_query, :query=>"foo's"}.should_not raise_error
    end

    it "should return empty result if no search param present" do
      get :auto_complete_for_search_query
      response.body.should be_blank
    end

    it "should return empty result if query is just blank spaces" do
      get :auto_complete_for_search_query, :query=>" "
      response.body.should be_blank
    end

    context "when searching in mobile mode" do
      before do
        @there_must_be_a_better_way_to_stub_this = ActionController::MobileFu::MOBILE_USER_AGENTS
        module ActionController::MobileFu
          remove_const :MOBILE_USER_AGENTS
        end
        ActionController::MobileFu::MOBILE_USER_AGENTS = "."
      end

      it "should return 6 suggestions" do
        Search.should_receive(:suggestions).with(nil, "lorem", 6)
        get :auto_complete_for_search_query, :query=>"lorem"
      end

      after do
        module ActionController::MobileFu
          remove_const :MOBILE_USER_AGENTS
        end
        ActionController::MobileFu::MOBILE_USER_AGENTS = @there_must_be_a_better_way_to_stub_this
      end
    end

    context "when searching in nonmobile mode" do
      it "should return 15 suggestions" do
        Search.should_receive(:suggestions).with(nil, "lorem", 15)
        get :auto_complete_for_search_query, :query=>"lorem"
      end
    end

    context "when searching from some other site on the internet" do
      it "should accept the 'q' parameter to work with jQuery's autocomplete syntax when style is set to 'jquery'" do
        SaytSuggestion.create(:phrase => "Lorem ipsum dolor sit amet")
        get :auto_complete_for_search_query, :q =>"lorem", :mode => 'jquery'
        response.body.should match(/lorem/i)
      end

      it "should return a carriagereturn separated list in jquery mode" do
        SaytSuggestion.create(:phrase => "Lorem ipsum dolor sit amet")
        SaytSuggestion.create(:phrase => "Lorem sic transit gloria")
        get :auto_complete_for_search_query, :q => "lorem", :mode => 'jquery', :callback => 'jsonp'
        response.body.should == 'jsonp(["lorem ipsum dolor sit amet","lorem sic transit gloria"])'
      end
    end
  end

  context "when showing index" do
    it "should have a route with a locale" do
      search_path.should =~ /search\?locale=en/
    end
  end

  context "when showing a new search" do
    integrate_views
    before do
      get :index, :query => "social security", :page => 4
      @search = assigns[:search]
      @page_title = assigns[:page_title]
    end

    should_render_template 'searches/index.html.haml', :layout => 'application'

    it "should assign the query as the page title" do
      @page_title.should == "social security"
    end

    it "should show a custom title for the results page" do
      response.body.should contain("social security - The U.S. Government's Official Web Search")
    end

    it "should set the query in the Search model" do
      @search.query.should == "social security"
    end

    it "should offset the start page in the Search model by one" do
      @search.page.should == 3
    end

    it "should load results for a keyword query" do
      @search.should_not be_nil
      @search.results.should_not be_nil
    end

    context "when a scope id is provided" do
      before do
        get :index, :query => 'obama', :scope_id => 'Scope'
      end

      it "should set the scope id parameter in the search options and the search, but not set a variable to be passed to the view" do
        assigns[:search_options][:scope_id].should == 'Scope'
        assigns[:search].scope_id.should == 'Scope'
        assigns[:scope_id].should be_nil
      end
    end
  end

  context "when handling a valid affiliate search request" do
    integrate_views
    before do
      @affiliate = affiliates(:power_affiliate)
      get :index, :affiliate=>@affiliate.name, :query => "weather"
      @search = assigns[:search]
      @page_title = assigns[:page_title]
    end

    should_assign_to :affiliate
    should_assign_to :page_title

    should_render_template 'searches/affiliate_index.html.haml', :layout => 'affiliate'

    it "should set an affiliate page title" do
      @page_title.should == "Search results for #{@affiliate.name}: #{@search.query}"
    end

    it "should render the header in the response" do
      response.body.should match(/#{@affiliate.header}/)
    end

    it "should render the footer in the response" do
      response.body.should match(/#{@affiliate.footer}/)
    end

    it "should not search for FAQs" do
      @search.faqs.should be_nil
      response.body.should_not match(/related_faqs/)
    end

    it "should not search for GovForms" do
      @search.gov_forms.should be_nil
      response.body.should_not match(/related_gov_forms/)
    end

    context "when a scope id is provided do" do
      before do
        get :index, :affiliate => @affiliate.name, :query => 'weather', :scope_id => 'SomeScope'
      end

      it "should set the scope id variable" do
        assigns[:scope_id].should == 'SomeScope'
      end
    end
  end

  context "when searching via the API" do
    integrate_views

    context "when searching normally" do
      before do
        get :index, :query => 'weather', :format => "json"
        @search = assigns[:search]
        @format = assigns[:original_format]
      end

      it "should set the format to json" do
        @format.to_s.should == "application/json"
      end

      it "should serialize the results into JSON" do
        response.body.should =~ /total/
        response.body.should =~ /startrecord/
        response.body.should =~ /endrecord/
      end
    end

    context "when some error is returned" do
      before do
        get :index, :query => 'a' * 1001, :format => "json"
        @search = assigns[:search]
      end

      it "should serialize an error into JSON" do
        response.body.should =~ /error/
        response.body.should =~ /#{I18n.translate :too_long}/
      end
    end
  end

  context "when handling any affiliate search request (mobile or otherwise)" do
    integrate_views
    before do
      get :index, :affiliate=> affiliates(:power_affiliate).name, :query => "weather"
    end

    should_render_template 'searches/affiliate_index.html.haml', :layout => 'affiliate'
  end

  context "when handling an invalid affiliate search request" do
    before do
      get :index, :affiliate=>"doesnotexist.gov", :query => "weather"
      @search = assigns[:search]
    end

    should_render_template 'searches/index.html.haml', :layout => 'application'
  end

  context "when handling any affiliate search request with a JSON format" do
    integrate_views
    before do
      get :index, :affiliate => affiliates(:power_affiliate).name, :query => "weather", :format => "json"
    end

    should_render_template 'searches/affiliate_index.html.haml', :layout => 'affiliate'
  end

  context "when handling a request that has FAQ results" do
    before do
      get :index, :query => 'uspto'
      @search = assigns[:search]
    end

    it "should search for FAQ results" do
      @search.should_not be_nil
      @search.faqs.should_not be_nil
    end
  end

  context "when handling a request that has FAQ results, but the FAQ records have been deleted from the database" do
    integrate_views
    before do
      Faq.destroy_all
      Faq.reindex
      Sunspot.commit
      Faq.search_for('uspto').total.should == 0
      @faq = Faq.create(:question => 'What is the USPTO?', :answer => 'The USPTO is a government agency', :url => 'http://uspto.gov', :ranking => 1)
      Sunspot.commit
      Faq.search_for('uspto').total.should == 1
      Faq.delete_all
      Faq.search_for('uspto').total.should == 1
      get :index, :query => 'uspto'
    end

    it "should display search results without Faq results" do
      response.should be_success
    end
  end

  context "when handling a request that has GovForm results" do
    before do
      get :index, :query => 'shell egg'
      @search = assigns[:search]
    end

    it "should search for GovForm results" do
      @search.should_not be_nil
      @search.gov_forms.should_not be_nil
    end
  end

  context "when handling a request that has GovForm results, but the GovForm records have been deleted from the database" do
    integrate_views
    before do
      GovForm.destroy_all
      GovForm.reindex
      Sunspot.commit
      GovForm.search_for('uspto').total.should == 0
      @gov_form = GovForm.create(:name => 'uspto GovForm', :form_number => 12345, :agency => 'UPSTO', :bureau => 'USPTO', :description => 'Something to do with the USPTO', :url => 'http://uspto.gov')
      Sunspot.commit
      GovForm.search_for('uspto').total.should == 1
      GovForm.delete_all
      GovForm.search_for('uspto').total.should == 1
      get :index, :query => 'uspto'
    end

    it "should display search results without GovForm results" do
      response.should be_success
    end
  end

  context "when a user is attempting to visit an old-style advanced search page" do
    before do
      get :index, :form => "advanced-firstgov"
    end

    it "should redirect to the advanced search page" do
      response.should redirect_to advanced_search_path(:form => 'advanced-firstgov')
    end
  end

  context "when a user is attempting to visit an old-style advanced search page for an affiliate" do
    before do
      get :index, :form => 'advanced-firstgov', :affiliate => 'aff.gov'
    end

    it "should redirect to the affiliate advanced search page" do
      response.should be_redirect
      redirect_to advanced_search_path(:affiliate => 'aff.gov', :form => 'advanced-firstgov')
    end
  end

  context "highlighting" do
    context "when a client requests results without highlighting" do
      before do
        get :index, :query => "obama", :hl => "false"
      end

      it "should set the highlighting option to false" do
        @search_options = assigns[:search_options]
        @search_options[:enable_highlighting].should be_false
      end
    end

    context "when a client requests result with highlighting" do
      before do
        get :index, :query => "obama", :hl => "true"
      end

      it "should set the highlighting option to true" do
        @search_options = assigns[:search_options]
        @search_options[:enable_highlighting].should be_true
      end
    end

    context "when a client does not specify highlighting" do
      before do
        get :index, :query => "obama"
      end

      it "should set the highlighting option to true" do
        @search_options = assigns[:search_options]
        @search_options[:enable_highlighting].should be_true
      end
    end
  end

  context "when omitting search textbox" do
    it "should omit the search textbox if the show_searchbox parameter is set to false and mobile mode is true" do
      get :index, :query => "obama", :show_searchbox => "false"
      assigns[:show_searchbox].should be_false
      response.body.should_not have_selector "search_form"
    end
  end

  describe "#advanced" do
    context "when an affiliate advanced search form is displayed" do
      context "when a valid scope id is specified" do
        before do
          get :index, :affiliate=> affiliates(:power_affiliate).name, :query => "weather", :scope_id => 'PatentClass'
        end

        it "should assign the scope id" do
          assigns[:scope_id].should == 'PatentClass'
        end
      end
    end
  end

  describe "#forms" do
    integrate_views
    
    context "when the source parameter is not specified" do
      before do
        GovForm.destroy_all
        @gov_form = GovForm.create(:name => "Tax Form", :form_number => "1040", :description => "A tax form", :agency => "IRS", :url => 'http://irs.gov/1040.pdf')
        GovForm.reindex
        get :forms, :query => "taxes", :page => 2
        @search = assigns[:search]
        @page_title = assigns[:page_title]
      end

      should_render_template 'searches/index.html.haml', :layout => 'application'

      it "should assign the query with a forms prefix as the page title" do
        @page_title.should == "Forms Search for: taxes"
      end

      it "should show a custom title for the results page" do
        response.body.should contain("Forms Search for: taxes - The U.S. Government's Official Web Search")
      end

      it "should set the query in the Search model" do
        @search.query.should == "taxes"
      end

      it "should offset the start page in the Search model by one" do
        @search.page.should == 1
      end

      it "should load results for a keyword query" do
        @search.should_not be_nil
        @search.results.should_not be_nil
      end
    
      it "should use the FormSearch model to do the search" do
        form_search_results = FormSearch.new(:query => 'taxes')
        FormSearch.should_receive(:new).with(:results_per_page => nil, :query => "taxes", :enable_highlighting => true, :page => 1).and_return form_search_results
        get :forms, :query => "taxes", :page => 2
      end
    
      it "should populate additional gov form results if the query matches" do
        @search.gov_forms.should_not be_nil
        @search.gov_forms.hits.should_not be_nil
        @search.gov_forms.total.should == 1
        @search.gov_forms.hits.first.instance.should_not be_nil
        @search.gov_forms.results.should_not be_empty
        @search.gov_forms.results.first.should == @gov_form
      end
        
      it "should render the search box with the form search path" do
        response.body.should have_tag("form#search_form[method=get][action=/search/forms?locale=en&amp;m=false]")
      end
    
      it "should not show any related search results" do
        @search.related_search.should be_empty
      end
    
      it "should have a Forms header at the top of the results, and link to Government Web and Images" do
        response.body.should have_tag("a[href=/search?m=false&amp;query=taxes]", :text => "Government Web")
        response.body.should have_tag("a[href=/search/images?m=false&amp;query=taxes]", :text => "Images")
        response.body.should have_tag("li", :text => "Forms")
      end
    
      it "should output a Forms GovBox with a link to more GovForm search results" do
        response.body.should have_tag("div[class=govbox]")
        response.body.should have_tag("a[href=/search/forms?locale=en&amp;m=false&amp;query=taxes&amp;source=gov_forms]", :text => "Forms for taxes")
        response.body.should have_tag("a[href=#{@gov_form.url}]", :text => "#{@gov_form.name} (#{@gov_form.form_number})")
      end
    
      it "should not have related Gov Forms" do
        response.body.should_not have_tag("ul[id=related_gov_forms]")
      end
    end
    
    context "when the source parameter is set to 'gov_forms'" do
      before do
        GovForm.destroy_all
        1.upto(12) do |index|
          GovForm.create(:name => "Taxes Form ##{index}", :form_number => index, :agency => 'GSA', :url => "http://forms.gov/#{index}.pdf", :description => 'A Government Tax Form')
        end
        GovForm.reindex
        get :forms, :query => "taxes", :source => 'gov_forms'
        @search = assigns[:search]
        @gov_forms = assigns[:gov_forms]
        @page_title = assigns[:page_title]        
      end
      
      should_render_template 'searches/forms.html.haml', :layout => 'application'
      
      it "should assign the query with a forms prefix as the page title" do
        @page_title.should == "Forms Search for: taxes"
      end

      it "should show a custom title for the results page" do
        response.body.should contain("Forms Search for: taxes - The U.S. Government's Official Web Search")
      end

      it "should set the query in the Search model" do
        @search.query.should == "taxes"
      end

      it "should assign results to the gov_forms variable" do
        @gov_forms.should_not be_nil
      end
      
      it "should output 10 GovForm results, linked to their URL" do
        1.upto(10) do |index|
          response.body.should have_tag("a[href=http://forms.gov/#{index}.pdf]", :text => "Taxes Form ##{index} (#{index})")
        end
        response.body.should_not have_tag("a[href=http://forms.gov/11.pdf]", :text => "Taxes Form #11 (11)")
      end
    end
  end
end