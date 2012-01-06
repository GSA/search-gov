require 'spec/spec_helper'

describe Affiliate do
  fixtures :users, :affiliates, :affiliate_templates

  before(:each) do
    @valid_create_attributes = {
      :display_name => "My Awesome Site",
      :website => "http://www.someaffiliate.gov",
      :header => "<table><tr><td>html layout from 1998</td></tr></table>",
      :footer => "<center>gasp</center>",
      :theme => "elegant",
      :locale => 'es'
    }
    @valid_attributes = @valid_create_attributes.merge(:name => "someaffiliate.gov")
  end

  describe "Creating new instance of Affiliate" do
    it { should validate_presence_of :display_name }
    SUPPORTED_LOCALES.each do |locale|
      it { should allow_value(locale).for(:locale) }
    end
    it { should_not allow_value("invalid_locale").for(:locale) }
    it { should validate_presence_of :locale }
    it { should validate_uniqueness_of(:name) }
    it { should ensure_length_of(:name).is_at_least(2).is_at_most(33) }
    ["<IMG SRC=", "259771935505'", "spacey name", "NewAff"].each do |value|
      it { should_not allow_value(value).for(:name) }
    end
    ["data.gov", "ct-new", "some_aff", "123"].each do |value|
      it { should allow_value(value).for(:name) }
    end
    it { should have_and_belong_to_many :users }
    it { should have_many :boosted_contents }
    it { should have_many :sayt_suggestions }
    it { should have_many(:popular_urls).dependent(:destroy) }
    it { should have_many(:featured_collections).dependent(:destroy) }
    it { should have_many(:rss_feeds).dependent(:destroy) }
    it { should have_many(:site_domains).dependent(:destroy)}
    it { should belong_to :affiliate_template }
    it { should belong_to :staged_affiliate_template }
    it { should_not allow_mass_assignment_of(:uses_one_serp) }
    it { should_not allow_mass_assignment_of(:header_footer_sass) }
    it { should_not allow_mass_assignment_of(:staged_header_footer_sass) }

    it "should create a new instance given valid attributes" do
      Affiliate.create!(@valid_create_attributes)
    end

    it "should generate Site Handle based on display name" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "Affiliate site"))
      affiliate.name.should == "affiliatesite"
    end

    describe "on create" do
      it "should generate Site Handle based on MD5 hash value when the display name is too short" do
        Digest::MD5.should_receive(:hexdigest).and_return("hexvalue")
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "A"))
        affiliate.name.should == "hexvalue"
      end

      it "should generate Site Handle based on MD5 hash value if display name contains less than 3 valid characters" do
        Digest::MD5.should_receive(:hexdigest).and_return("hexvalue")
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "3!!"))
        affiliate.name.should == "hexvalue"
      end

      it "should generate Site Handle using MD5 hash value when the candidate Site Handle already exists" do
        Digest::MD5.should_receive(:hexdigest).and_return("hexvalue")
        first_affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "Affiliate site123___----...."))
        first_affiliate.name.should == "affiliatesite123___----...."
        second_affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "Affiliate site123___----...."))
        second_affiliate.name.should == "hexvalue"
      end

      it "should generate Site Handle with 33 characters if display name is greater than 33 characters" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "1234567890!!1234567890!!1234567890!!123456"))
        affiliate.name.should == "123456789012345678901234567890123"
      end

      it "should generate Site Handle with 3 characters if display name is 3 characters" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "123"))
        affiliate.name.should == "123"
      end

      it "should set default search_results_page_title if search_results_page_title is blank" do
        affiliate = Affiliate.create!(@valid_create_attributes)
        affiliate.search_results_page_title.should == "{Query} - {SiteName} Search Results"
      end

      it "should set default staged_search_results_page_title if staged_search_results_page_title is blank" do
        affiliate = Affiliate.create!(@valid_create_attributes)
        affiliate.staged_search_results_page_title.should == "{Query} - {SiteName} Search Results"
      end

      it "should update css_properties with json string from css property hash" do
        css_property_hash = { 'title_link_color' => '#33ff33', 'visited_title_link_color' => '#0000ff' }
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:css_property_hash => css_property_hash))
        JSON.parse(affiliate.css_properties, :symbolize_names => true).should == css_property_hash
      end

      it "should update staged_css_properties with json string from staged_css property hash" do
        staged_css_property_hash = { 'title_link_color' => '#33ff33', 'visited_title_link_color' => '#0000ff' }
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:staged_css_property_hash => staged_css_property_hash))
        JSON.parse(affiliate.staged_css_properties).should == staged_css_property_hash
      end

      it "should set one_serp field to true" do
        affiliate = Affiliate.create!(@valid_create_attributes)
        affiliate.uses_one_serp?.should be_true
      end

      it "should be valid when FONT_FAMILIES includes font_family in css property hash" do
        Affiliate::FONT_FAMILIES.each do |font_family|
          Affiliate.new(@valid_create_attributes.merge(:css_property_hash => { 'font_family' => font_family })).should be_valid
        end
      end

      it "should not be valid when FONT_FAMILIES does not include font_family in css property hash" do
        Affiliate.new(@valid_create_attributes.merge(:css_property_hash => { 'font_family' => 'Comic Sans MS' })).should_not be_valid
      end

      it "should be valid when color property in css property hash consists of a # character followed by 3 or 6 hexadecimal digits " do
        %w{ #333 #FFF #fff #12F #666666 #666FFF #FFFfff #ffffff }.each do |valid_color|
          Affiliate.new(@valid_create_attributes.merge(
                            :css_property_hash => { 'left_tab_text_color' => "#{valid_color}",
                                                    'title_link_color' => "#{valid_color}",
                                                    'visited_title_link_color' => "#{valid_color}",
                                                    'description_text_color' => "#{valid_color}",
                                                    'url_link_color' => "#{valid_color}" })).should be_valid
        end
      end

      it "should be invalid when color property in css property hash does not consist of a # character followed by 3 or 6 hexadecimal digits " do
        %w{ 333 invalid #err #1 #22 #4444 #55555 ffffff 1 22 4444 55555 666666 }.each do |invalid_color|
          affiliate = Affiliate.new(@valid_create_attributes.merge(
                                        :css_property_hash => { 'left_tab_text_color' => "#{invalid_color}",
                                                                'title_link_color' => "#{invalid_color}",
                                                                'visited_title_link_color' => "#{invalid_color}",
                                                                'description_text_color' => "#{invalid_color}",
                                                                'url_link_color' => "#{invalid_color}" }))
          affiliate.should_not be_valid
          affiliate.errors[:base].should include("Title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
          affiliate.errors[:base].should include("Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
          affiliate.errors[:base].should include("Description text color should consist of a # character followed by 3 or 6 hexadecimal digits")
          affiliate.errors[:base].should include("Url link color should consist of a # character followed by 3 or 6 hexadecimal digits")
        end
      end

      it "should validate color property in staged css property hash" do
        affiliate = Affiliate.new(@valid_create_attributes.merge(:staged_css_property_hash => { 'title_link_color' => 'invalid', 'visited_title_link_color' => '#err' }))
        affiliate.save.should be_false
        affiliate.errors[:base].should include("Title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
        affiliate.errors[:base].should include("Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
      end

      it "should validate header_footer_css" do
        { :header_footer_css => "h1 { invalid: }", :staged_header_footer_css => "h1 { invalid: }" }.each do |key, value|
        affiliate = Affiliate.new(@valid_create_attributes.merge(key => value))
        affiliate.save.should be_false
        affiliate.errors[:base].first.should match(/CSS for the top and bottom of your search results page: Invalid CSS/)
        end
      end

      it "should normalize site domains" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(
                                          :site_domains_attributes => { '0' => { :domain => 'www1.usa.gov' },
                                                                        '1' => { :domain => 'www2.usa.gov' },
                                                                        '2' => { :domain => 'usa.gov' } }))
        affiliate.site_domains(true).count.should == 1
        affiliate.site_domains.first.domain.should == 'usa.gov'
      end
      
      it "should default the govbox fields to OFF" do
        affiliate = Affiliate.create!(@valid_create_attributes)
        affiliate.is_agency_govbox_enabled.should == false
        affiliate.is_medline_govbox_enabled.should == false
      end
    end

    describe "on update_attributes_for_staging" do
      let(:affiliate) { Affiliate.create!(@valid_create_attributes) }
      let(:staged_css_property_hash) { { 'font_family' => 'Verdana, sans-serif',
                                         'title_link_color' => '#111',
                                         'visited_title_link_color' => '#222',
                                         'description_text_color' => '#444',
                                         'url_link_color' => '#555' } }

      before do
        @update_params = { :staged_header_footer_css => ".staged h1 { color: blue; }",
                           :staged_header => "<span>header</span>",
                           :staged_footer => "<span>footer</span>",
                           :staged_affiliate_template_id => affiliate_templates(:basic_gray).id,
                           :staged_search_results_page_title => "updated - {query} - {sitename} Search Results",
                           :staged_theme => Affiliate::THEMES.keys.first.to_s,
                           :staged_css_property_hash =>  staged_css_property_hash }
      end

      it "should set has_staged_content to true" do
        affiliate.has_staged_content.should be_false
        affiliate.update_attributes_for_staging(@update_params).should be_true
        affiliate.has_staged_content.should be_true
      end

      it "should update staged attributes" do
        affiliate.update_attributes_for_staging(@update_params).should be_true
        affiliate.staged_header_footer_css.should == @update_params[:staged_header_footer_css]
        affiliate.staged_header.should == @update_params[:staged_header]
        affiliate.staged_footer.should == @update_params[:staged_footer]
        affiliate.staged_affiliate_template_id.should == @update_params[:staged_affiliate_template_id]
        affiliate.staged_search_results_page_title.should == @update_params[:staged_search_results_page_title]
        affiliate.staged_theme.should == @update_params[:staged_theme]
        JSON.parse(affiliate.staged_css_properties).should == @update_params[:staged_css_property_hash]
      end

      it "should save staged favicon URL with http:// prefix when it does not start with http(s)://" do
        url = 'cdn.agency.gov/staged_favicon.ico'
        prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
        prefixes.each do |prefix|
          affiliate.update_attributes_for_staging(@update_params.merge(:staged_favicon_url => "#{prefix}#{url}")).should be_true
          affiliate.staged_favicon_url.should == "http://#{prefix}#{url}"
        end
      end

      it "should save staged favicon URL as is when it starts with http(s)://" do
        url = 'cdn.agency.gov/staged_favicon.ico'
        prefixes = %w( http:// https:// HTTP:// HTTPS:// )
        prefixes.each do |prefix|
          affiliate.update_attributes_for_staging(@update_params.merge(:staged_favicon_url => "#{prefix}#{url}")).should be_true
          affiliate.staged_favicon_url.should == "#{prefix}#{url}"
        end
      end

      it "should save staged external CSS URL with http:// prefix when it does not start with http(s)://" do
        url = 'cdn.agency.gov/custom.css'
        prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
        prefixes.each do |prefix|
          affiliate.update_attributes_for_staging(@update_params.merge(:staged_external_css_url => "#{prefix}#{url}")).should be_true
          affiliate.staged_external_css_url.should == "http://#{prefix}#{url}"
        end
      end

      it "should save staged external CSS URL as is when it starts with http(s)://" do
        url = 'cdn.agency.gov/custom.css'
        prefixes = %w( http:// https:// HTTP:// HTTPS:// )
        prefixes.each do |prefix|
          affiliate.update_attributes_for_staging(@update_params.merge(:staged_external_css_url => "#{prefix}#{url}")).should be_true
          affiliate.staged_external_css_url.should == "#{prefix}#{url}"
        end
      end

      it "should set staged header and footer sass" do
        affiliate.update_attributes_for_staging(@update_params)
        affiliate.staged_header_footer_sass.should == "  .staged h1\n    color: blue"
      end
    end

    describe "on update_attributes_for_current" do
      let(:affiliate) { Affiliate.create!(@valid_create_attributes) }

      before do
        @update_params = {:staged_header_footer_css => ".staged h1 { color: blue; }",
                          :staged_header => "<span>header</span>",
                          :staged_footer => "<span>footer</span>",
                          :staged_affiliate_template_id => affiliate_templates(:basic_gray).id,
                          :staged_search_results_page_title => "updated - {query} - {sitename} Search Results",
                          :staged_theme => Affiliate::THEMES.keys.first,
                          :staged_css_properties => { 'title_link_color' => '#ffffff', 'visited_title_link_color' => '00ff00' }.to_json }
      end

      it "should store a copy of the previous version of the header and footer" do
        original_header, original_footer = affiliate.header, affiliate.footer
        affiliate.update_attributes_for_current(@update_params).should be_true
        affiliate.previous_header.should == original_header
        affiliate.previous_footer.should == original_footer
      end

      it "should set has_staged_content to false" do
        affiliate.has_staged_content.should be_false
        affiliate.update_attributes_for_current(@update_params).should be_true
        affiliate.has_staged_content.should be_false
      end

      it "should update current attributes" do
        affiliate.update_attributes_for_current(@update_params).should be_true
        affiliate.header_footer_css.should == @update_params[:staged_header_footer_css]
        affiliate.header.should == @update_params[:staged_header]
        affiliate.footer.should == @update_params[:staged_footer]
        affiliate.affiliate_template_id.should == @update_params[:staged_affiliate_template_id]
        affiliate.search_results_page_title.should == @update_params[:staged_search_results_page_title]
        affiliate.theme.should == @update_params[:staged_theme]
        affiliate.css_properties.should == @update_params[:staged_css_properties]
        affiliate.staged_header_footer_css.should == @update_params[:staged_header_footer_css]
        affiliate.staged_header.should == @update_params[:staged_header]
        affiliate.staged_footer.should == @update_params[:staged_footer]
        affiliate.staged_affiliate_template_id.should == @update_params[:staged_affiliate_template_id]
        affiliate.staged_search_results_page_title.should == @update_params[:staged_search_results_page_title]
        affiliate.staged_theme.should == @update_params[:staged_theme]
        affiliate.staged_css_properties.should == @update_params[:staged_css_properties]
      end

      it "should save favicon URL with http:// prefix when it does not start with http(s)://" do
        url = 'cdn.agency.gov/favicon.ico'
        prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
        prefixes.each do |prefix|
          affiliate.update_attributes_for_current(@update_params.merge(:staged_favicon_url => "#{prefix}#{url}")).should be_true
          affiliate.staged_favicon_url.should == "http://#{prefix}#{url}"
          affiliate.favicon_url.should == "http://#{prefix}#{url}"
        end
      end

      it "should save favicon URL as is when it starts with http(s)://" do
        url = 'cdn.agency.gov/favicon.ico'
        prefixes = %w( http:// https:// HTTP:// HTTPS:// )
        prefixes.each do |prefix|
          affiliate.update_attributes_for_current(@update_params.merge(:staged_favicon_url => "#{prefix}#{url}")).should be_true
          affiliate.staged_favicon_url.should == "#{prefix}#{url}"
          affiliate.favicon_url.should == "#{prefix}#{url}"
        end
      end

      it "should save external CSS URL with http:// prefix when it does not start with http(s)://" do
        url = 'cdn.agency.gov/custom.css'
        prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
        prefixes.each do |prefix|
          affiliate.update_attributes_for_current(@update_params.merge(:staged_external_css_url => "#{prefix}#{url}")).should be_true
          affiliate.staged_external_css_url.should == "http://#{prefix}#{url}"
          affiliate.external_css_url.should == "http://#{prefix}#{url}"
        end
      end

      it "should save external CSS URL as is when it starts with http(s)://" do
        url = 'cdn.agency.gov/custom.css'
        prefixes = %w( http:// https:// HTTP:// HTTPS:// )
        prefixes.each do |prefix|
          affiliate.update_attributes_for_current(@update_params.merge(:staged_external_css_url => "#{prefix}#{url}")).should be_true
          affiliate.staged_external_css_url.should == "#{prefix}#{url}"
          affiliate.external_css_url.should == "#{prefix}#{url}"
        end
      end

      it "should set header footer sass" do
        affiliate.update_attributes_for_current(@update_params)
        affiliate.header_footer_sass.should == "  .staged h1\n    color: blue"
      end
    end

    it "should not change the name attribute on update" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      lambda { affiliate.update_attributes(:name => "") }.should raise_error("This field cannot be changed.")
      affiliate.name.should == "myawesomesite"
    end

    it "should validate presence of :search_results_page_title on update" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.update_attributes(:search_results_page_title => "").should_not be_true
    end

    it "should validate presence of :staged_search_results_page_title on update" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.update_attributes(:staged_search_results_page_title => "").should_not be_true
    end

    it "should have SAYT enabled by default" do
      Affiliate.create!(@valid_create_attributes).is_sayt_enabled.should be_true
    end

    it "should generate a database-level error when attempting to add an affiliate with the same name as an existing affiliate, but with different case; instead it should return false" do
      Affiliate.create!(@valid_attributes)
      @duplicate_affiliate = Affiliate.new(@valid_attributes.merge(:name => @valid_attributes[:name].upcase))
      @duplicate_affiliate.save.should be_false
    end

    it "should set the affiliate_template_id to the default affiliate_template_id" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.affiliate_template.should == affiliate_templates(:default)
    end

    it "should set the affiliate_template_id to the default affiliate_template_id" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
    end
  end

  describe "#template" do
    it "should return the affiliate template if present" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
      affiliate.template.should == affiliate.affiliate_template
    end

    it "should return the default affiliate template if no affiliate template" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:affiliate_template_id => -1))
      affiliate.affiliate_template.should be_nil
      affiliate.template.should == AffiliateTemplate.default_template
    end
  end

  describe "on save" do
    it "should set the affiliate_template_id to the default affiliate_template_id if saved with no affiliate_template_id" do
      affiliate = Affiliate.new(@valid_create_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.uses_one_serp = false
      affiliate.save!
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
      Affiliate.find(affiliate.id).update_attributes(:affiliate_template_id => "")
      Affiliate.find(affiliate.id).affiliate_template.should == affiliate_templates(:default)
    end

    context "when affiliate does not use serp" do
      let(:affiliate) { Affiliate.new(@valid_create_attributes.merge(:theme => nil)) }

      before do
        affiliate.uses_one_serp = false
        affiliate.save!
        affiliate.uses_one_serp.should_not be_true
        affiliate.theme.should be_blank
        affiliate.staged_theme.should be_blank
      end

      it "should set theme when uses_one_serp is set to true" do
        affiliate.uses_one_serp = true
        affiliate.save!
        affiliate.theme.should == 'default'
        affiliate.staged_theme.should == 'default'
      end
    end
  end

  describe "#is_affiliate_related_topics_enabled?" do
    it "should return true if the value of related_topics_setting is nil" do
      affiliate = Affiliate.create(@valid_create_attributes.merge(:related_topics_setting => nil))
      affiliate.is_affiliate_related_topics_enabled?.should be_true
    end

    it "should return true if the value of related_topics_setting is 'affiliate_enabled'" do
      affiliate = Affiliate.create(@valid_create_attributes.merge(:related_topics_setting => 'affiliate_enabled'))
      affiliate.is_affiliate_related_topics_enabled?.should be_true
    end

    it "should return true if the value is set to anything other than 'global_enabled' or 'disabled'" do
      affiliate = Affiliate.create(@valid_create_attributes.merge(:related_topics_setting => 'bananas'))
      affiliate.is_affiliate_related_topics_enabled?.should be_true
      affiliate = Affiliate.create(@valid_create_attributes.merge(:related_topics_setting => 'global_enabled'))
      affiliate.is_affiliate_related_topics_enabled?.should be_false
      affiliate = Affiliate.create(@valid_create_attributes.merge(:related_topics_setting => 'disabled'))
      affiliate.is_affiliate_related_topics_enabled?.should be_false
    end
  end

  describe "#human_attribute_name" do
    Affiliate.human_attribute_name("display_name").should == "Site name"
    Affiliate.human_attribute_name("name").should == "Site Handle (visible to searchers in the URL)"
    Affiliate.human_attribute_name("staged_search_results_page_title").should == "Search results page title"
  end

  describe "#build_search_results_page_title" do
    let(:affiliate) { Affiliate.create(@valid_create_attributes) }

    it "should handle nil query" do
      affiliate.build_search_results_page_title(nil).should == " - My Awesome Site Search Results"
    end

    it "should return default search results page title" do
      affiliate.build_search_results_page_title("gov").should == "gov - My Awesome Site Search Results"
    end

    it "should return search results page title with updated format" do
      affiliate.update_attributes! :search_results_page_title => "{SiteName} Search Results: {Query}"
      affiliate.build_search_results_page_title("healthcare").should == "My Awesome Site Search Results: healthcare"
    end

    it "should return plain search results page title when search_results_page_title field does not contain special format" do
      affiliate.update_attributes! :search_results_page_title => "Plain Search Results Page"
      affiliate.build_search_results_page_title("healthcare").should == "Plain Search Results Page"
    end
  end

  describe "#build_staged_search_results_page_title" do
    let(:affiliate) { Affiliate.create(@valid_create_attributes) }

    it "should handle nil query" do
      affiliate.build_staged_search_results_page_title(nil).should == " - My Awesome Site Search Results"
    end

    it "should return default staged search results page title" do
      affiliate.build_staged_search_results_page_title("gov").should == "gov - My Awesome Site Search Results"
    end

    it "should return staged search results page title with updated format" do
      affiliate.update_attributes! :staged_search_results_page_title => "{SiteName} Search Results: {Query}"
      affiliate.build_staged_search_results_page_title("healthcare").should == "My Awesome Site Search Results: healthcare"
    end

    it "should return plain staged search results page title when staged_search_results_page_title field does not contain special format" do
      affiliate.update_attributes! :staged_search_results_page_title => "Plain Search Results Page"
      affiliate.build_staged_search_results_page_title("healthcare").should == "Plain Search Results Page"
    end
  end

  describe "#staging_attributes" do
    let(:create_staged_attributes) {
      { :staged_header_footer_css => ".staged h1 { color: blue; }",
        :staged_header => '<h1>staged header</h1>',
        :staged_footer => '<h1>staged footer</h1>',
        :staged_affiliate_template => affiliate_templates(:basic_gray),
        :staged_search_results_page_title => 'custom serp title',
        :staged_favicon_url => 'http://cdn.agency.gov/favicon.ico',
        :staged_external_css_url => 'http://cdn.agency.gov/custom.css',
        :staged_theme => Affiliate::THEMES.keys.first.to_s,
        :staged_css_properties => { 'title_link_color' => '#888888' }.to_json } }

    let(:staged_attributes) {
      create_staged_attributes.merge(:staged_affiliate_template_id => affiliate_templates(:basic_gray).id).except(:staged_affiliate_template)
    }

    let(:affiliate) { Affiliate.create(@valid_create_attributes.merge(create_staged_attributes)) }

    context "when initialized" do
      it "should return all staging attributes" do
        [:staged_header_footer_css, :staged_header, :staged_footer,
         :staged_affiliate_template_id, :staged_search_results_page_title,
         :staged_favicon_url, :staged_external_css_url, :staged_theme, :staged_css_properties].each do |key|
          affiliate.staging_attributes.should include(key)
        end
      end

      specify { affiliate.staging_attributes.should == staged_attributes }
    end
  end

  describe "#cancel_staged_changes" do
    let(:affiliate) { Affiliate.create!(@valid_create_attributes) }
    let(:staged_css_properties) { { 'font_family' => 'Verdana, sans-serif',
                                    'title_link_color' => '#111',
                                    'visited_title_link_color' => '#222',
                                    'description_text_color' => '#444',
                                    'url_link_color' => '#555' }.to_json }

    before do
      @update_params = { :staged_header_footer_css => ".staged h1 { color: blue; }",
                         :staged_header => "<span>header</span>",
                         :staged_footer => "<span>footer</span>",
                         :staged_affiliate_template_id => affiliate_templates(:basic_gray).id,
                         :staged_search_results_page_title => "updated - {query} - {sitename} Search Results",
                         :staged_favicon_url => 'http://cdn.agency.gov/staged_favicon.ico',
                         :staged_external_css_url => "http://cdn.agency.gov/staged_custom.css",
                         :staged_theme => Affiliate::THEMES.keys.first.to_s,
                         :staged_css_properties => staged_css_properties }
      affiliate.update_attributes_for_staging(@update_params).should be_true
    end

    it "should overwrite all staged attributes with non staged attributes" do
      affiliate.cancel_staged_changes
      affiliate.staged_header_footer_css.should_not == @update_params[:staged_header_footer_css]
      affiliate.staged_header.should_not == @update_params[:staged_header]
      affiliate.staged_footer.should_not == @update_params[:staged_footer]
      affiliate.staged_affiliate_template_id.should_not == @update_params[:staged_affiliate_template_id]
      affiliate.staged_search_results_page_title.should_not == @update_params[:staged_search_results_page_title]
      affiliate.staged_favicon_url.should_not == @update_params[:staged_favicon_url]
      affiliate.staged_external_css_url.should_not == @update_params[:staged_external_css_url]
      affiliate.staged_theme.should_not == @update_params[:staged_theme]
      affiliate.staged_css_properties.should_not == @update_params[:staged_css_properties]
    end

    it "should not have staged content" do
      affiliate.has_staged_content = true
      affiliate.cancel_staged_changes
      affiliate.has_staged_content = false
    end
  end

  describe "#ordered" do
    it "should include a scope called 'ordered'" do
      Affiliate.scopes.include?(:ordered).should be_true
    end
  end

  describe "#sync_staged_attributes" do
    context "when the affiliate has staged content" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      before do
        affiliate.should_receive(:has_staged_content?).and_return(false)
        affiliate.should_receive(:cancel_staged_changes).and_return(true)
      end

      specify { affiliate.sync_staged_attributes.should be_true }
    end

    context "when the affiliate does not have staged content" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      before do
        affiliate.should_receive(:has_staged_content?).and_return(true)
        affiliate.should_not_receive(:cancel_staged_changes)
      end

      specify { affiliate.sync_staged_attributes.should be_nil }
    end
  end

  describe "#domains_as_array" do
    before do
      @affiliate = Affiliate.create!(@valid_create_attributes)
      @affiliate.add_site_domains('one.domain.com' => nil, 'two.domain.com' => nil)
    end

    it "should return an array" do
      @affiliate.domains_as_array.is_a?(Array).should be_true
    end

    it "should have two entries split on line break" do
      @affiliate.domains_as_array.size.should == 2
      @affiliate.domains_as_array.should == %w( one.domain.com two.domain.com )
    end

    context "when domains is nil" do
      before do
        @affiliate = Affiliate.create!(@valid_create_attributes)
      end

      it "should not error when called, and return empty" do
        @affiliate.domains_as_array.should == []
      end
    end
  end

  describe "#has_multiple_domains?" do
    let(:affiliate) { Affiliate.create!(@valid_create_attributes) }

    context "when Affiliate has more than 1 domain" do
      before do
        affiliate.add_site_domains('foo.gov' => nil, 'bar.gov' => nil)
      end

      specify { affiliate.should have_multiple_domains }
    end

    context "when Affiliate has no domain" do
      specify { affiliate.should_not have_multiple_domains }
    end

    context "when Affiliate has 1 domain" do
      before do
        affiliate.add_site_domains('foo.gov' => nil)
      end
      specify { affiliate.should_not have_multiple_domains }
    end
  end

  describe "#css_property_hash" do
    context "when theme is custom" do
      let(:css_property_hash) { { :title_link_color => '#33ff33', :visited_title_link_color => '#0000ff' } }
      let(:affiliate) { Affiliate.create!(@valid_create_attributes.merge(:theme => 'custom', :css_properties => css_property_hash.to_json)) }

      specify { affiliate.css_property_hash.should == css_property_hash }
    end

    context "when theme is not custom" do
      let(:css_property_hash) { { :font_family => Affiliate::FONT_FAMILIES.last } }
      let(:affiliate) { Affiliate.create!(
          @valid_create_attributes.merge(:theme => 'elegant',
                                         :css_properties => css_property_hash.to_json)) }

      specify { affiliate.css_property_hash.should == Affiliate::THEMES[:elegant].merge(css_property_hash) }
    end
  end

  describe "#staged_css_property_hash" do
    context "when theme is custom" do
      let(:staged_css_property_hash) { { :title_link_color => '#33ff33', :visited_title_link_color => '#0000ff' } }
      let(:affiliate) { Affiliate.create!(@valid_create_attributes.merge(:theme => 'natural', :staged_theme => 'custom', :staged_css_properties => staged_css_property_hash.to_json)) }

      specify { affiliate.staged_css_property_hash.should == staged_css_property_hash }
    end

    context "when theme is not custom" do
      let(:staged_css_property_hash) { { :font_family => Affiliate::FONT_FAMILIES.last } }
      let(:affiliate) { Affiliate.create!(
          @valid_create_attributes.merge(:theme => 'natural',
                                         :staged_theme => 'elegant',
                                         :staged_css_properties => staged_css_property_hash.to_json)) }

      specify { affiliate.staged_css_property_hash.should == Affiliate::THEMES[:elegant].merge(staged_css_property_hash) }
    end
  end

  describe "scope_ids_as_array" do
    context "when an affiliate has a non-null scope_ids attribute" do
      before do
        @affiliate = Affiliate.new(:scope_ids => 'Scope1,Scope2,Scope3')
      end

      it "should return the scopes as an array" do
        @affiliate.scope_ids_as_array.should == ['Scope1', 'Scope2', 'Scope3']
      end
    end

    context "when the scope_ids have spaces near the commas" do
      before do
        @affiliate = Affiliate.new(:scope_ids => "Scope1, Scope2, Scope3")
      end

      it "should strip out whitespace" do
        @affiliate.scope_ids_as_array.should == ['Scope1', 'Scope2', 'Scope3']
      end
    end

    context "when an affiliate has a nil scope_ids attribute" do
      before do
        @affiliate = Affiliate.new
      end

      it "should return an empty array" do
        @affiliate.scope_ids_as_array.should == []
      end
    end
  end

  describe "#add_site_domains" do
    let(:affiliate) { affiliate = Affiliate.create!(@valid_create_attributes) }

    context "when input domains have leading http(s) protocols" do
      it "should delete leading http(s) protocols from domains" do
        site_domain_hash = ActiveSupport::OrderedHash["http://foo.gov", nil, "bar.gov/somepage.html", nil, "https://blat.gov/somedir", nil]
        added_site_domains = affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains(true)
        site_domains.should == added_site_domains
        site_domains[0].domain.should == "foo.gov"
        site_domains[1].domain.should == "blat.gov/somedir"
        site_domains[2].domain.should == "bar.gov/somepage.html"
      end
    end

    context "when input domains have blank/whitespace" do
      it "should delete blank/whitespace from domains" do
        site_domain_hash = ActiveSupport::OrderedHash[" do.gov ", nil, " bar.gov", nil, "blat.gov ", nil]
        added_site_domains = affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains(true)
        site_domains.should == added_site_domains
        site_domains[0].domain.should == "do.gov"
        site_domains[1].domain.should == "bar.gov"
        site_domains[2].domain.should == "blat.gov"
      end
    end

    context "when input domains have dupes" do
      before do
        affiliate.add_site_domains("foo.gov" => nil)
      end

      it "should delete dupes from domains" do
        affiliate.add_site_domains('foo.gov' => nil).should be_empty

        site_domains = affiliate.site_domains(true)
        site_domains.count.should == 1
        site_domains.first.domain.should == 'foo.gov'
      end
    end

    context "when input domains don't look like domains" do
      it "should filter them out" do
        site_domain_hash = ActiveSupport::OrderedHash['foo.gov', nil, 'somepage.html', nil, 'whatisthis?', nil, 'bar.gov/somedir/', nil]
        added_site_domains = affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains(true)
        site_domains.should == added_site_domains
        site_domains.count.should == 2
        site_domains[0].domain.should == 'foo.gov'
        site_domains[1].domain.should == 'bar.gov/somedir/'
      end
    end

    context "when one input domain is covered by another" do
      it "should filter it out" do
        site_domain_hash = ActiveSupport::OrderedHash['blat.gov', nil, 'blat.gov/s.html', nil, 'bar.gov/somedir/', nil, 'bar.gov', nil, 'www.bar.gov', nil, 'xxbar.gov', nil]
        added_site_domains = affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains(true)
        site_domains.should == added_site_domains
        site_domains.count.should == 3
        site_domains[0].domain.should == 'bar.gov'
        site_domains[1].domain.should == 'blat.gov'
        site_domains[2].domain.should == 'xxbar.gov'
      end
    end

    context "when existing domains are covered by new ones" do
      let(:domains) { %w( a.foo.gov b.foo.gov y.bar.gov z.bar.gov c.foo.gov agency.gov ) }

      before do
        site_domain_hash = Hash[domains.collect { |domain| [domain, nil] }]
        affiliate.add_site_domains(site_domain_hash)
        SiteDomain.where(:affiliate_id => affiliate.id).count.should == 6
      end

      it "should filter out existing domains" do
        added_site_domains = affiliate.add_site_domains({ 'foo.gov' => nil, 'bar.gov' => nil })

        added_site_domains.count.should == 2
        site_domains = affiliate.site_domains(true)
        site_domains.count.should == 3
        site_domains[0].domain.should == 'agency.gov'
        site_domains[1].domain.should == 'bar.gov'
        site_domains[2].domain.should == 'foo.gov'
      end
    end
  end

  describe "#update_site_domain" do
    let(:affiliate) { affiliate = Affiliate.create!(@valid_create_attributes) }
    let(:site_domain) { SiteDomain.find_by_affiliate_id_and_domain(affiliate.id, 'www.gsa.gov') }

    context "when existing domain is covered by new ones" do
      before do
        affiliate.add_site_domains({ 'www1.usa.gov' => nil, 'www2.usa.gov' => nil, 'www.gsa.gov' => nil })
        SiteDomain.where(:affiliate_id => affiliate.id).count.should == 3
      end

      it "should filter out existing domains" do
        affiliate.update_site_domain(site_domain, { :domain => 'usa.gov', :site_name => nil }).should be_true

        site_domains = affiliate.site_domains(true)
        site_domains.count.should == 1
        site_domains.first.domain.should == 'usa.gov'
      end
    end
  end
end
