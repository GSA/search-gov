# coding: utf-8
require 'spec_helper'

describe Affiliate do
  fixtures :users, :affiliates, :site_domains, :features, :youtube_profiles, :memberships, :languages, :affiliate_templates

  let(:valid_create_attributes) do
    { display_name: 'My Awesome Site',
      name: 'myawesomesite',
      website: 'http://www.someaffiliate.gov',
      header: '<table><tr><td>html layout from 1998</td></tr></table>',
      footer: '<center>gasp</center>',
      locale: 'es' }.freeze
   end
   let(:valid_attributes) { valid_create_attributes.merge(name: 'someaffiliate.gov').freeze }
   let(:affiliate) { Affiliate.new(valid_create_attributes) }

  describe 'schema' do
    it { should have_db_column(:i14y_date_stamp_enabled).of_type(:boolean).with_options(default: false, null: false) }
    it { should have_db_column(:active_template_id).of_type(:integer) }

    it { should have_db_index(:active_template_id) }

    it { should have_attached_file :page_background_image }
    it { should have_attached_file :header_image }
    it { should have_attached_file :mobile_logo }
    it { should have_attached_file :header_tagline_logo }

    it { should have_attached_file :rackspace_page_background_image }
    it { should have_attached_file :rackspace_header_image }
    it { should have_attached_file :rackspace_mobile_logo }
    it { should have_attached_file :rackspace_header_tagline_logo }
  end

  describe "Creating new instance of Affiliate" do
    it { should validate_presence_of :display_name }
    Language.pluck(:code).each do |locale|
      it { should allow_value(locale).for(:locale) }
    end
    it { should validate_presence_of :locale }
    it { should validate_uniqueness_of(:api_access_key).case_insensitive }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should ensure_length_of(:name).is_at_least(2).is_at_most(33) }
    ["<IMG SRC=", "259771935505'", "spacey name"].each do |value|
      it { should_not allow_value(value).for(:name) }
    end
    %w{data.gov ct-new some_aff 123 NewAff}.each do |value|
      it { should allow_value(value).for(:name) }
    end

    it { should have_many :boosted_contents }
    it { should have_many :sayt_suggestions }
    it { should have_many :twitter_profiles }

    it { should have_many(:routed_query_keywords).through :routed_queries }
    it { should have_many(:rss_feed_urls).through :rss_feeds }
    it { should have_many(:users).through :memberships }

    it { should have_many(:affiliate_feature_addition).dependent(:destroy) }
    it { should have_many(:affiliate_twitter_settings).dependent(:destroy) }
    it { should have_many(:excluded_domains).dependent(:destroy) }
    it { should have_many(:featured_collections).dependent(:destroy) }
    it { should have_many(:features).dependent(:destroy) }
    it { should have_many(:flickr_profiles).dependent(:destroy) }
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:navigations).dependent(:destroy) }
    it { should have_many(:routed_queries).dependent(:destroy) }
    it { should have_many(:rss_feeds).dependent(:destroy) }
    it { should have_many(:affiliate_templates) }
    it { should have_many(:site_domains).dependent(:destroy) }
    it { should have_many(:tag_filters).dependent(:destroy) }

    it { should have_and_belong_to_many :instagram_profiles }
    it { should have_and_belong_to_many :youtube_profiles }

    it { should belong_to :agency }
    it { should belong_to :language }

    it { should_not allow_mass_assignment_of(:previous_fields_json) }
    it { should_not allow_mass_assignment_of(:live_fields_json) }
    it { should_not allow_mass_assignment_of(:staged_fields_json) }

    it { should validate_attachment_content_type(:page_background_image).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }
    it { should validate_attachment_content_type(:header_image).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }
    it { should validate_attachment_content_type(:mobile_logo).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }

    it "should create a new instance given valid attributes" do
      Affiliate.create!(valid_create_attributes)
    end

    it "should downcase the name if it's uppercase" do
      affiliate = Affiliate.new(valid_create_attributes)
      affiliate.name = 'AffiliateSite'
      affiliate.save!
      affiliate.name.should == "affiliatesite"
    end

    describe "on create" do
      it "should update css_properties with json string from css property hash" do
        css_property_hash = {'title_link_color' => '#33ff33', 'visited_title_link_color' => '#0000ff'}
        affiliate = Affiliate.create!(valid_create_attributes.merge(:css_property_hash => css_property_hash))
        JSON.parse(affiliate.css_properties, :symbolize_names => true)[:title_link_color].should == '#33ff33'
        JSON.parse(affiliate.css_properties, :symbolize_names => true)[:visited_title_link_color].should == '#0000ff'
      end

      it "sets the Keen scoped key" do
        KeenScopedKey.stub(:generate).and_return 'some key'
        affiliate = Affiliate.create!(valid_create_attributes)
        affiliate.scoped_key.key.should eq('some key')
      end

      it "should normalize site domains" do
        affiliate = Affiliate.create!(valid_create_attributes.merge(
                                          site_domains_attributes: { '0' => { domain: 'www1.usa.gov' },
                                                                     '1' => { domain: 'www2.usa.gov' },
                                                                     '2' => { domain: 'usa.gov' } }))
        affiliate.site_domains(true).count.should == 1
        affiliate.site_domains.first.domain.should == 'usa.gov'

        affiliate = Affiliate.create!(
            valid_create_attributes.merge(
                name: 'anothersite',
                site_domains_attributes: { '0' => { domain: 'sec.gov' },
                                           '1' => { domain: 'www.sec.gov.staging.net' } }))
        expect(affiliate.site_domains(true).count).to eq(2)
        expect(affiliate.site_domains.pluck(:domain).sort).to eq(%w(sec.gov www.sec.gov.staging.net))
      end

      it "should default the govbox fields to OFF" do
        affiliate = Affiliate.create!(valid_create_attributes)
        affiliate.is_medline_govbox_enabled.should == false
      end

      it "should have SAYT enabled by default" do
        Affiliate.create!(valid_create_attributes).is_sayt_enabled.should be_true
      end

      it "should generate a database-level error when attempting to add an affiliate with the same name as an existing affiliate, but with different case; instead it should return false" do
        affiliate = Affiliate.new(valid_attributes, :as => :test)
        affiliate.name = valid_attributes[:name]
        affiliate.save!
        duplicate_affiliate = Affiliate.new(valid_attributes, :as => :test)
        duplicate_affiliate.name = valid_attributes[:name].upcase
        duplicate_affiliate.save.should be_false
      end

      it "should populate default search label for English site" do
        affiliate = Affiliate.create!(valid_attributes.merge(:locale => 'en'), :as => :test)
        affiliate.default_search_label.should == 'Everything'
      end

      it "should populate default search labels for Spanish site" do
        affiliate = Affiliate.create!(valid_attributes.merge(:locale => 'es'), :as => :test)
        affiliate.default_search_label.should == 'Todo'
      end

      it 'should set look_and_feel_css' do
        affiliate = Affiliate.create! valid_attributes

        expect(affiliate.look_and_feel_css).to include('font-family:"Maven Pro"')
        expect(affiliate.look_and_feel_css).to match(/#usasearch_footer_button\{color:#fff;background-color:#00396f\}\n$/)
        expect(affiliate.look_and_feel_css).to include('#usasearch_footer.managed a:visited{color:#00396f}')
        expect(affiliate.mobile_look_and_feel_css).to include('a:visited{color:purple}')
      end

      it 'assigns api_access_key' do
        affiliate = Affiliate.create! valid_attributes
        expect(affiliate.api_access_key).to be_present
      end
    end
  end

  describe "on save" do
    let(:affiliate) { Affiliate.create!(valid_create_attributes) }

    it 'should not override default theme attributes' do
      affiliate.theme = 'default'
      affiliate.css_property_hash = {:page_background_color => '#FFFFFF'}
      affiliate.save!
      Affiliate.find(affiliate.id).css_property_hash[:page_background_color].should == Affiliate::THEMES[:default][:page_background_color]
    end

    it "should save favicon URL with http:// prefix when it does not start with http(s)://" do
      url = 'cdn.agency.gov/favicon.ico'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        affiliate.update_attributes!(favicon_url: "#{prefix}#{url}")
        affiliate.favicon_url.should == "http://#{prefix}#{url}"
      end
    end

    it "should save favicon URL as is when it starts with http(s)://" do
      url = 'cdn.agency.gov/favicon.ico'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        affiliate.update_attributes(favicon_url: "#{prefix}#{url}")
        affiliate.favicon_url.should == "#{prefix}#{url}"
      end
    end

    it "should save external CSS URL with http:// prefix when it does not start with http(s)://" do
      url = 'cdn.agency.gov/custom.css'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        affiliate.update_attributes!(:external_css_url => "#{prefix}#{url}")
        affiliate.external_css_url.should == "http://#{prefix}#{url}"
      end
    end

    it "should save external CSS URL as is when it starts with http(s)://" do
      url = 'cdn.agency.gov/custom.css'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        affiliate.update_attributes!(:external_css_url => "#{prefix}#{url}")
        affiliate.external_css_url.should == "#{prefix}#{url}"
      end
    end

    it 'should prefix website with http://' do
      affiliate.update_attributes!(website: 'usa.gov')
      affiliate.website.should == 'http://usa.gov'
    end

    it "should set css properties" do
      affiliate.css_property_hash = { font_family: 'Verdana, sans-serif' }
      affiliate.save!
      Affiliate.find(affiliate.id).css_property_hash[:font_family].should == 'Verdana, sans-serif'
    end

    it "should not set header_footer_nested_css fields" do
      affiliate.update_attributes!(staged_header_footer_css: '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }', header_footer_css: '')
      affiliate.staged_nested_header_footer_css.should be_blank
      affiliate.header_footer_css.should be_blank
      affiliate.update_attributes!(staged_header_footer_css: '', header_footer_css: '@charset "UTF-8"; @import url("other.css"); live.h1 { color: red }')
      affiliate.staged_nested_header_footer_css.should be_blank
      affiliate.nested_header_footer_css.should be_blank
    end

    it "should set previous json fields" do
      affiliate.previous_header = 'previous header'
      affiliate.previous_footer = 'previous footer'
      affiliate.save!
      Affiliate.find(affiliate.id).previous_header.should == 'previous header'
      Affiliate.find(affiliate.id).previous_footer.should == 'previous footer'
    end

    it "should set staged and live json fields" do
      affiliate.header = 'live header'
      affiliate.footer = 'live footer'
      affiliate.staged_header = 'staged header'
      affiliate.staged_footer = 'staged footer'
      affiliate.save!
      Affiliate.find(affiliate.id).header.should == 'live header'
      Affiliate.find(affiliate.id).footer.should == 'live footer'
      Affiliate.find(affiliate.id).staged_header.should == 'staged header'
      Affiliate.find(affiliate.id).staged_footer.should == 'staged footer'
    end

    it "should populate search labels for English site" do
      english_affiliate = Affiliate.create!(valid_attributes.merge(:locale => 'en'), :as => :test)
      english_affiliate.default_search_label = ''
      english_affiliate.save!
      english_affiliate.default_search_label.should == 'Everything'
    end

    it "should populate search labels for Spanish site" do
      spanish_affiliate = Affiliate.create!(valid_attributes.merge(:locale => 'es'), :as => :test)
      spanish_affiliate.default_search_label = ''
      spanish_affiliate.save!
      spanish_affiliate.default_search_label.should == 'Todo'
    end

    it "should squish string columns" do
      affiliate = Affiliate.create!(valid_create_attributes)
      unsquished_attributes = {
        ga_web_property_id: ' GA Web Property  ID  ',
        header_tagline_font_size: ' 12px ',
        logo_alt_text: ' this  is   my   logo ',
        navigation_dropdown_label: '  My   Location  ',
        related_sites_dropdown_label: '  More   related   sites  '
      }.freeze

      affiliate.update_attributes!(unsquished_attributes)

      affiliate = Affiliate.find affiliate.id
      expect(affiliate.ga_web_property_id).to eq('GA Web Property ID')
      expect(affiliate.header_tagline_font_size).to eq('12px')
      expect(affiliate.logo_alt_text).to eq('this is my logo')
      expect(affiliate.navigation_dropdown_label).to eq('My Location')
      expect(affiliate.related_sites_dropdown_label).to eq('More related sites')
    end


    it 'should set default RSS govbox label if the value is blank' do
      en_affiliate = Affiliate.create!(valid_create_attributes.merge(locale: 'en'))
      en_affiliate.rss_govbox_label.should == 'News'
      en_affiliate.update_attributes!(rss_govbox_label: '')
      en_affiliate.rss_govbox_label.should == 'News'

      es_affiliate = Affiliate.create!(valid_create_attributes.merge(locale: 'es', name: 'es-site'))
      es_affiliate.rss_govbox_label.should == 'Noticias'
      es_affiliate.update_attributes!({ rss_govbox_label: '' })
      es_affiliate.rss_govbox_label.should == 'Noticias'
    end

    it 'should remove comments from staged_header and staged_footer fields' do
        html_with_comments = <<-HTML
        <div class="level1">
          <!--[if IE]>
          <script src="http://cdn.agency.gov/script.js"></script>
          According to the conditional comment this is IE<br />
          <![endif]-->
          <span>level1</span>
          <div class="level2">
            <span>level2</span>
            <!--[if IE]>
            <script src="http://cdn.agency.gov/script.js"></script>
            According to the conditional comment this is IE<br />
            <![endif]-->
            <div class="level3">
              <!--[if IE]>
              <script src="http://cdn.agency.gov/script.js"></script>
              According to the conditional comment this is IE<br />
              <![endif]-->
              <span>level3</span>
            </div>
          </div>
        </div>
        HTML

        html_without_comments = <<-HTML
        <div class="level1">
          <span>level1</span>
          <div class="level2">
            <span>level2</span>
            <div class="level3">
              <span>level3</span>
            </div>
          </div>
        </div>
        HTML
        affiliate.update_attributes!(:staged_header => html_with_comments, :staged_footer => html_with_comments)
        Affiliate.find(affiliate.id).staged_header.squish.should == html_without_comments.squish
        Affiliate.find(affiliate.id).staged_footer.squish.should == html_without_comments.squish
    end

    it 'should squish related sites dropdown label' do
      affiliate = Affiliate.create!(valid_create_attributes.merge(locale: 'en', name: 'en-site'))
      affiliate.related_sites_dropdown_label = ' Search  Only'
      affiliate.save!
      expect(affiliate.related_sites_dropdown_label).to eq('Search Only')
    end

    it 'should set blank related sites dropdown label to nil' do
      affiliate = Affiliate.create!(valid_create_attributes.merge(locale: 'en', name: 'en-site'))
      affiliate.related_sites_dropdown_label = ' '
      affiliate.save!
      expect(affiliate.related_sites_dropdown_label).to be_nil
    end
  end

  describe "on destroy" do
    let(:affiliate) { Affiliate.create!(display_name: 'connecting affiliate', name: 'anothersite') }
    let(:connected_affiliate) { Affiliate.create!(display_name: 'connected affiliate', name: 'connectedsite') }

    it "should destroy connection" do
      affiliate.connections.create!(:connected_affiliate => connected_affiliate, :label => 'search connected affiliate')
      Affiliate.find(affiliate.id).connections.count.should == 1
      connected_affiliate.destroy
      Affiliate.find(affiliate.id).connections.count.should == 0
    end
  end

  describe "validations" do
    it "should be valid when FONT_FAMILIES includes font_family in css property hash" do
      FontFamily::ALL.each do |font_family|
        Affiliate.new(valid_create_attributes.merge(:css_property_hash => {'font_family' => font_family})).should be_valid
      end
    end

    it "should not be valid when FONT_FAMILIES does not include font_family in css property hash" do
      Affiliate.new(valid_create_attributes.merge(:css_property_hash => {'font_family' => 'Comic Sans MS'})).should_not be_valid
    end

    it "should be valid when color property in css property hash consists of a # character followed by 3 or 6 hexadecimal digits " do
      %w{ #333 #FFF #fff #12F #666666 #666FFF #FFFfff #ffffff }.each do |valid_color|
        css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({'left_tab_text_color' => "#{valid_color}",
                                                                          'title_link_color' => "#{valid_color}",
                                                                          'visited_title_link_color' => "#{valid_color}",
                                                                          'description_text_color' => "#{valid_color}",
                                                                          'url_link_color' => "#{valid_color}"})
        Affiliate.new(valid_create_attributes.merge(:css_property_hash => css_property_hash)).should be_valid
      end
    end

    it "should be invalid when color property in css property hash does not consist of a # character followed by 3 or 6 hexadecimal digits " do
      %w{ 333 invalid #err #1 #22 #4444 #55555 ffffff 1 22 4444 55555 666666 }.each do |invalid_color|
        css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({'left_tab_text_color' => "#{invalid_color}",
                                                                          'title_link_color' => "#{invalid_color}",
                                                                          'visited_title_link_color' => "#{invalid_color}",
                                                                          'description_text_color' => "#{invalid_color}",
                                                                          'url_link_color' => "#{invalid_color}"})
        affiliate = Affiliate.new(valid_create_attributes.merge(:css_property_hash => css_property_hash))
        affiliate.should_not be_valid
        affiliate.errors[:base].should include("Title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
        affiliate.errors[:base].should include("Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
        affiliate.errors[:base].should include("Description text color should consist of a # character followed by 3 or 6 hexadecimal digits")
        affiliate.errors[:base].should include("Url link color should consist of a # character followed by 3 or 6 hexadecimal digits")
      end
    end

    it "should validate color property in staged css property hash" do
      css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({'title_link_color' => 'invalid', 'visited_title_link_color' => '#DDDD'})
      affiliate = Affiliate.new(valid_create_attributes.merge(:css_property_hash => css_property_hash))
      affiliate.save.should be_false
      affiliate.errors[:base].should include("Title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
      affiliate.errors[:base].should include("Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
    end

    it 'validates logo alignment' do
      Affiliate.new(valid_create_attributes.merge(
                        css_property_hash: { 'logo_alignment' => 'invalid' })).should_not be_valid
    end

    it "should not validate header_footer_css" do
      affiliate = Affiliate.new(valid_create_attributes.merge(:header_footer_css => "h1 { invalid-css-syntax }"))
      affiliate.save.should be_true

      affiliate = Affiliate.new(valid_create_attributes.merge(:header_footer_css => "h1 { color: #DDDD }", name: 'anothersite'))
      affiliate.save.should be_true
    end

    it "should not validate staged_header_footer_css for invalid css property value" do
      affiliate = Affiliate.new(valid_create_attributes.merge(staged_header_footer_css: 'h1 { invalid-css-syntax }'))
      affiliate.save.should be_true

      affiliate = Affiliate.new(valid_create_attributes.merge(staged_header_footer_css: 'h1 { color: #DDDD }', name: 'anothersite'))
      affiliate.save.should be_true
    end

    it 'validates locale is valid' do
      affiliate = Affiliate.new(valid_create_attributes.merge(locale: 'invalid_locale'))
      affiliate.save.should be_false
      affiliate.errors[:base].should include("Locale must be valid")
    end

    context "is_validate_staged_header_footer is set to true" do
      let(:affiliate) { Affiliate.create!(display_name: 'test header footer validation',
                                          name: 'testheaderfootervalidation',
                                          uses_managed_header_footer: false,
                                          staged_uses_managed_header_footer: false) }

      before { affiliate.is_validate_staged_header_footer = true }

      it "should not allow form, script, style or link elements in staged header or staged footer" do
        header_error_message = %q(HTML to customize the top of your search results page must not contain form, script, style, link elements)
        footer_error_message = %q(HTML to customize the bottom of your search results page must not contain form, script, style, link elements)

        html_with_script = <<-HTML
            <script src="http://cdn.agency.gov/script.js"></script>
            <h1>html with script</h1>
        HTML
        affiliate.update_attributes(:staged_header => html_with_script, :staged_footer => html_with_script).should be_false
        affiliate.errors[:base].join.should match(/#{header_error_message}/)
        affiliate.errors[:base].join.should match(/#{footer_error_message}/)

        html_with_style = <<-HTML
            <style>#my_header { color:red }</style>
            <h1>html with style</h1>
        HTML
        affiliate.update_attributes(:staged_header => html_with_style, :staged_footer => html_with_style).should be_false
        affiliate.errors[:base].join.should match(/#{header_error_message}/)
        affiliate.errors[:base].join.should match(/#{footer_error_message}/)

        html_with_link = <<-HTML
            <link href="http://cdn.agency.gov/link.css" />
            <h1>html with link</h1>
        HTML
        affiliate.update_attributes(:staged_header => html_with_link, :staged_footer => html_with_link).should be_false
        affiliate.errors[:base].join.should match(/#{header_error_message}/)
        affiliate.errors[:base].join.should match(/#{footer_error_message}/)

        html_with_form = <<-HTML
            <form></form>
            <h1>html with link</h1>
        HTML
        affiliate.update_attributes(:staged_header => html_with_form, :staged_footer => html_with_form).should be_false
        affiliate.errors[:base].join.should match(/#{header_error_message}/)
        affiliate.errors[:base].join.should match(/#{footer_error_message}/)
      end

      it 'should not allow onload attribute in staged header or staged footer' do
        header_error_message = %q(HTML to customize the top of your search results page must not contain the onload attribute)
        footer_error_message = %q(HTML to customize the bottom of your search results page must not contain the onload attribute)

        html_with_onload = <<-HTML
          <div onload="cdn.agency.gov/script.js"></div>
          <h1>html with onload</h1>
        HTML

        affiliate.update_attributes(:staged_header => html_with_onload, :staged_footer => html_with_onload).should be_false
        affiliate.errors[:base].join.should match(/#{header_error_message}/)
        affiliate.errors[:base].join.should match(/#{footer_error_message}/)
      end

      it "should not allow malformed HTML in staged header or staged footer" do
        header_error_message = 'HTML to customize the top of your search results is invalid'
        footer_error_message = 'HTML to customize the bottom of your search results is invalid'

        html_with_body = <<-HTML
            <html><body><h1>html with script</h1></body></html>
        HTML
        affiliate.update_attributes(:staged_header => html_with_body, :staged_footer => html_with_body).should be_false
        affiliate.errors[:base].join.should include("#{header_error_message}")
        affiliate.errors[:base].join.should include("#{footer_error_message}")

        malformed_html_fragments = <<-HTML
            <link href="http://cdn.agency.gov/link.css"></script>
            <h1>html with link</h1>
        HTML
        affiliate.update_attributes(:staged_header => malformed_html_fragments, :staged_footer => malformed_html_fragments).should be_false
        affiliate.errors[:base].join.should include("#{header_error_message}")
        affiliate.errors[:base].join.should include("#{footer_error_message}")
      end

      it "should not validate header_footer_css" do
        affiliate.update_attributes(:header_footer_css => "h1 { invalid-css-syntax }").should be_true
        affiliate.update_attributes(:header_footer_css => "h1 { color: #DDDD }").should be_true
      end

      it "should validate staged_header_footer_css for invalid css property value" do
        affiliate.update_attributes(:staged_header_footer_css => "h1 { invalid-css-syntax }").should be_false
        affiliate.errors[:base].first.should match(/Invalid CSS/)

        affiliate.update_attributes(:staged_header_footer_css => "h1 { color: #DDDD }").should be_false
        affiliate.errors[:base].first.should match(/Colors must have either three or six digits/)
      end
    end

    context "is_validate_staged_header_footer is set to false" do
      let(:affiliate) { Affiliate.create!(display_name: 'test header footer validation',
                                          name: 'testheaderfootervalidation',
                                          uses_managed_header_footer: false,
                                          staged_uses_managed_header_footer: false) }
      it "should allow script, style or link elements in staged header or staged footer" do
        affiliate.is_validate_staged_header_footer = false

        html_with_script = <<-HTML
            <script src="http://cdn.agency.gov/script.js"></script>
            <h1>html with script</h1>
        HTML
        affiliate.update_attributes(:staged_header => html_with_script, :staged_footer => html_with_script).should be_true
      end
    end

    it 'allows valid external tracking code' do
      expect { Affiliate.create!({ display_name: 'a site',
                                   external_tracking_code: '<script>var a;</script>',
                                   name: 'external-tracking-site'}) }.to_not raise_error
    end

    it 'should not allow malformed external tracking code' do
      expect { Affiliate.create!({ display_name: 'a site',
                                   footer_fragment: '<script>var a;',
                                   name: 'external-tracking-site'}) }.to raise_error
    end

    it 'allows valid external tracking code' do
      expect { Affiliate.create!({ display_name: 'a site',
                                   footer_fragment: '<script>var a;</script>',
                                   name: 'footer-fragment-site'}) }.to_not raise_error
    end

    it 'should not allow malformed footer_fragment' do
      expect { Affiliate.create!({ display_name: 'a site',
                                   footer_fragment: '<script>var a;',
                                   name: 'footer-fragment-site'}) }.to raise_error
    end
  end

  describe "#update_attributes_for_staging" do
    it "should set has_staged_content to true and receive update_attributes" do
      affiliate = Affiliate.create!(valid_create_attributes)
      attributes = mock('attributes')
      attributes.should_receive(:[]).with(:staged_uses_managed_header_footer).and_return('0')
      attributes.should_receive(:[]=).with(:has_staged_content, true)
      return_value = mock('return value')
      affiliate.should_receive(:update_attributes).with(attributes).and_return(return_value)
      affiliate.update_attributes_for_staging(attributes).should == return_value
    end

    context "when attributes contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to true" do
        affiliate = Affiliate.create!(display_name: 'oneserp affiliate', name: 'oneserpaffiliate')
        affiliate.should_receive(:is_validate_staged_header_footer=).with(true)
        affiliate.update_attributes_for_staging(:staged_uses_managed_header_footer => '0',
                                                :staged_header => 'staged header',
                                                :staged_footer => 'staged footer')
      end

      it "should set header_footer_nested_css fields" do
        affiliate = Affiliate.create!(valid_create_attributes)
        affiliate.update_attributes!(:header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }')
        affiliate.update_attributes_for_staging(
          :staged_uses_managed_header_footer => '0',
          :staged_header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }').should be_true
        affiliate.staged_nested_header_footer_css.squish.should =~ /^#{Regexp.escape('.header-footer h1{color:blue}')}$/
      end

      it 'should not validated live header_footer_css field' do
        affiliate = Affiliate.create!(valid_create_attributes)
        affiliate.update_attributes!(:header_footer_css => 'h1 { invalid-css-syntax }')
        affiliate.update_attributes_for_staging(
          :staged_uses_managed_header_footer => '0',
          :staged_header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }').should be_true
        affiliate.staged_nested_header_footer_css.squish.should =~ /^#{Regexp.escape('.header-footer h1{color:blue}')}$/
      end
    end

    context "when attributes does not contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to false" do
        affiliate = Affiliate.create!(display_name: 'oneserp affiliate', name: 'oneserpaffiliate')
        affiliate.should_receive(:is_validate_staged_header_footer=).with(false)
        affiliate.update_attributes_for_staging(staged_uses_managed_header_footer: '1')
      end
    end
  end

  describe "#update_attributes_for_live" do
    let(:affiliate) { Affiliate.create!(valid_create_attributes.merge(:header => 'old header', :footer => 'old footer')) }

    context "when successfully update_attributes" do
      before do
        affiliate.should_receive(:update_attributes).and_return(true)
      end

      it "should set previous fields" do
        affiliate.should_receive(:previous_header=).with('old header')
        affiliate.should_receive(:previous_footer=).with('old footer')
        affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer').should be_true
      end

      it "should set attributes from staged to live" do
        affiliate.should_receive(:set_attributes_from_staged_to_live)
        affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer').should be_true
      end

      it "should set has_staged_content to false" do
        affiliate.should_receive(:has_staged_content=).with(false)
        affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer').should be_true
      end

      it "should save!" do
        affiliate.should_receive(:save!)
        affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer').should be_true
      end
    end

    context "when update_attributes failed" do
      before do
        affiliate.should_receive(:update_attributes).and_return(false)
        affiliate.should_not_receive(:previous_header=)
        affiliate.should_not_receive(:previous_footer=)
        affiliate.should_not_receive(:save!)
      end

      specify { affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer').should be_false }
    end

    context "when attributes contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to true" do
        affiliate.should_receive(:is_validate_staged_header_footer=).with(true)
        affiliate.update_attributes_for_live(:staged_uses_managed_header_footer => '0',
                                             :staged_header => 'staged header',
                                             :staged_footer => 'staged footer')
      end

      it "should set header_footer_nested_css fields" do
        affiliate = Affiliate.create!(valid_create_attributes)
        affiliate.update_attributes_for_live(
          :staged_uses_managed_header_footer => '0',
          :staged_header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }').should be_true
        affiliate.staged_nested_header_footer_css.squish.should =~ /^#{Regexp.escape('.header-footer h1{color:blue}')}$/
        affiliate.nested_header_footer_css.squish.should =~ /^#{Regexp.escape('.header-footer h1{color:blue}')}$/
      end

      it 'should not validated live header_footer_css field' do
        affiliate = Affiliate.create!(valid_create_attributes)
        affiliate.update_attributes!(:header_footer_css => 'h1 { invalid-css-syntax }')
        affiliate.update_attributes_for_live(
          :staged_uses_managed_header_footer => '0',
          :staged_header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }').should be_true
        affiliate.staged_nested_header_footer_css.squish.should =~ /^#{Regexp.escape('.header-footer h1{color:blue}')}$/
        affiliate.nested_header_footer_css.squish.should =~ /^#{Regexp.escape('.header-footer h1{color:blue}')}$/
      end
    end

    context "when attributes does not contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to false" do
        affiliate.should_receive(:is_validate_staged_header_footer=).with(false)
        affiliate.update_attributes_for_live(staged_uses_managed_header_footer: '1')
      end
    end
  end

  describe "#set_attributes_from_staged_to_live" do
    let(:affiliate) { Affiliate.create!(valid_create_attributes) }

    it "should set live fields with values from staged fields" do
      Affiliate::ATTRIBUTES_WITH_STAGED_AND_LIVE.each do |attribute|
        staged_value = mock("staged_value for #{attribute}")
        affiliate.should_receive("staged_#{attribute}".to_sym).and_return(staged_value)
        affiliate.should_receive("#{attribute}=".to_sym).with(staged_value)
      end
      affiliate.set_attributes_from_staged_to_live
    end
  end

  describe "#set_attributes_from_live_to_staged" do
    let(:affiliate) { Affiliate.create!(valid_create_attributes) }

    it "should set staged fields with values from live fields" do
      Affiliate::ATTRIBUTES_WITH_STAGED_AND_LIVE.each do |attribute|
        live_value = mock("live_value for #{attribute}")
        affiliate.should_receive("#{attribute}".to_sym).and_return(live_value)
        affiliate.should_receive("staged_#{attribute}=".to_sym).with(live_value)
      end
      affiliate.set_attributes_from_live_to_staged
    end
  end

  describe '.human_attribute_name' do
    specify { Affiliate.human_attribute_name('display_name').should == 'Display name' }
    specify { Affiliate.human_attribute_name('name').should == 'Site Handle (visible to searchers in the URL)' }
  end

  describe "#push_staged_changes" do
    it "should set attributes from staged to live fields, set has_staged_content to false and save!" do
      affiliate = Affiliate.create!(valid_create_attributes)
      affiliate.should_receive(:set_attributes_from_staged_to_live)
      affiliate.should_receive(:has_staged_content=).with(false)
      affiliate.should_receive(:save!)
      affiliate.push_staged_changes
    end
  end

  describe "#cancel_staged_changes" do
    it "should set attributes from live to staged fields, set has_staged_content to false and save!" do
      affiliate = Affiliate.create!(valid_create_attributes)
      affiliate.should_receive(:set_attributes_from_live_to_staged)
      affiliate.should_receive(:has_staged_content=).with(false)
      affiliate.should_receive(:save!)
      affiliate.cancel_staged_changes
    end

    it 'should copy header_footer_css' do
      affiliate = Affiliate.create!(valid_create_attributes)
      affiliate.update_attributes!(:header_footer_css => 'h1 { invalid-css-syntax }',
                                   :nested_header_footer_css => '.header_footer h1 { invalid-css-syntax }')
      Affiliate.find(affiliate.id).cancel_staged_changes

      aff_after_cancel = Affiliate.find(affiliate.id)
      aff_after_cancel.staged_header_footer_css.should == 'h1 { invalid-css-syntax }'
      aff_after_cancel.staged_nested_header_footer_css.should == '.header_footer h1 { invalid-css-syntax }'
    end
  end

  describe "#ordered" do
    it "should include a scope called 'ordered'" do
      Affiliate.ordered.should_not be_nil
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

  describe "#has_multiple_domains?" do
    let(:affiliate) { Affiliate.create!(valid_create_attributes) }

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

  describe "#recent_user_activity" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate_manager) { users(:another_affiliate_manager) }
    let(:affiliate_manager_with_one_site) { users(:affiliate_manager_with_one_site) }
    let(:recent_time) { Time.now }

    before do
      affiliate.users.first.update_attribute(:last_request_at, recent_time)
      affiliate.users << another_affiliate_manager
      affiliate.users.last.update_attribute(:last_request_at, recent_time - 1.hour)
      affiliate.users << affiliate_manager_with_one_site
      affiliate.users.last.update_attribute(:last_request_at, nil)
    end

    it 'should show the max last_request_at date for the site users' do
      affiliate.recent_user_activity.utc.to_s.should == recent_time.utc.to_s
    end
  end

  describe "#has_no_social_image_feeds?" do
    let(:affiliate) { affiliates(:basic_affiliate) }

    context 'when affiliate has no flickr/instagram/mrss profiles' do
      before do
        affiliate.flickr_profiles.delete_all
        affiliate.instagram_profiles.delete_all
        affiliate.rss_feeds.mrss.delete_all
      end
      specify { affiliate.should have_no_social_image_feeds }
    end

    context 'when affiliate has MRSS feed but the RSS feed URL has no Oasis MRSS name' do
      before do
        affiliate.flickr_profiles.delete_all
        affiliate.instagram_profiles.delete_all
        affiliate.rss_feeds.mrss.delete_all
        feed = affiliate.rss_feeds.build(name: "mrss", show_only_media_content: true)
        feed.rss_feed_urls.build(url: "http://www.defense.gov/news/mrss_leadphotos.xml", last_crawl_status: 'OK',
                                 oasis_mrss_name: nil, rss_feed_owner_type: "Affiliate")
        feed.rss_feed_urls.first.stub(:url_must_point_to_a_feed) { true }
        feed.save!
      end
      specify { affiliate.should have_no_social_image_feeds }
    end
  end

  describe "#css_property_hash" do
    context "when theme is custom" do
      let(:css_property_hash) { {:title_link_color => '#33ff33', :visited_title_link_color => '#0000ff'}.reverse_merge(Affiliate::DEFAULT_CSS_PROPERTIES) }
      let(:affiliate) { Affiliate.create!(valid_create_attributes.merge(:theme => 'custom', :css_property_hash => css_property_hash)) }

      specify { affiliate.css_property_hash(true).should == css_property_hash }
    end

    context 'when theme is default' do
      let(:css_property_hash) { { font_family: FontFamily::ALL.last } }
      let(:affiliate) { Affiliate.create!(
        valid_create_attributes.merge(theme: 'default',
                                       css_property_hash: css_property_hash)) }

      specify { affiliate.css_property_hash(true).should == Affiliate::THEMES[:default].merge(css_property_hash) }
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
    let(:affiliate) { Affiliate.create!(valid_create_attributes) }

    context "when input domains have leading http(s) protocols" do
      it "should delete leading http(s) protocols from domains" do
        site_domain_hash = ActiveSupport::OrderedHash["http://foo.gov", nil, "bar.gov/somepage.html", nil, "https://blat.gov/somedir", nil]
        affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains(true)
        site_domains.size.should == 2
        site_domains.collect(&:domain).sort.should == %w{blat.gov/somedir foo.gov}
      end
    end

    context "when input domains have blank/whitespace" do
      it "should delete blank/whitespace from domains" do
        site_domain_hash = ActiveSupport::OrderedHash[" do.gov ", nil, " bar.gov", nil, "blat.gov ", nil]
        affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains(true)
        site_domains.size.should == 3
        site_domains.collect(&:domain).sort.should == %w{bar.gov blat.gov do.gov}
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
        site_domain_hash = ActiveSupport::OrderedHash['foo.gov', nil, 'somepage.info', nil, 'whatisthis?', nil, 'bar.gov/somedir/', nil]
        affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains(true)
        site_domains.count.should == 3
        site_domains.collect(&:domain).sort.should == %w{bar.gov/somedir foo.gov somepage.info}
      end
    end

    context "when one input domain is covered by another" do
      it "should filter it out" do
        site_domain_hash = ActiveSupport::OrderedHash['blat.gov', nil, 'blat.gov/s.html', nil, 'bar.gov/somedir/', nil, 'bar.gov', nil, 'www.bar.gov', nil, 'xxbar.gov', nil]
        added_site_domains = affiliate.add_site_domains(site_domain_hash)

        site_domain_names = affiliate.site_domains(true).map(&:domain)
        expect(added_site_domains.map(&:domain)).to eq(site_domain_names)
        expect(site_domain_names).to eq(%w(bar.gov blat.gov xxbar.gov))
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
        added_site_domains = affiliate.add_site_domains({'foo.gov' => nil, 'bar.gov' => nil})

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
    let(:affiliate) {  Affiliate.create!(valid_create_attributes) }
    let(:site_domain) { SiteDomain.find_by_affiliate_id_and_domain(affiliate.id, 'www.gsa.gov') }

    context "when existing domain is covered by new ones" do
      before do
        affiliate.add_site_domains({'www1.usa.gov' => nil, 'www2.usa.gov' => nil, 'www.gsa.gov' => nil})
        SiteDomain.where(:affiliate_id => affiliate.id).count.should == 3
      end

      it "should filter out existing domains" do
        affiliate.update_site_domain(site_domain, {:domain => 'usa.gov', :site_name => nil}).should be_true

        site_domains = affiliate.site_domains(true)
        site_domains.count.should == 1
        site_domains.first.domain.should == 'usa.gov'
      end
    end
  end

  describe "#refresh_indexed_documents(scope)" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @affiliate.fetch_concurrency = 2
      @first = @affiliate.indexed_documents.build(:title => 'Document Title 1', :description => 'This is a Document.', :url => 'http://nps.gov/')
      @second = @affiliate.indexed_documents.build(:title => 'Document Title 2', :description => 'This is a Document 2.', :url => 'http://nps.gov/foo')
      @third = @affiliate.indexed_documents.build(:title => 'Document Title 3', :description => 'This is a Document 3.', :url => 'http://nps.gov/bar')
      @ok = @affiliate.indexed_documents.build(:title => 'PDF Title',
                                               :description => 'This is a PDF document.',
                                               :url => 'http://nps.gov/pdf.pdf',
                                               :last_crawl_status => IndexedDocument::OK_STATUS,
                                               :last_crawled_at => Time.now,
                                               :body => "this is the doc body")
      @affiliate.save!
    end

    it "should enqueue just the scoped docs in batches" do
      Resque.should_receive(:enqueue_with_priority).with(:low, AffiliateIndexedDocumentFetcher, @affiliate.id, @first.id, @second.id, 'not_ok')
      Resque.should_receive(:enqueue_with_priority).with(:low, AffiliateIndexedDocumentFetcher, @affiliate.id, @third.id, @third.id, 'not_ok')
      @affiliate.refresh_indexed_documents('not_ok')
    end
  end

  describe "#sanitized_header" do
    it "should remove all banned HTML elements" do
      tainted_header = <<-HTML
        <script src="http://cdn.agency.gov/script.js"></script>
        <link href="http://cdn.agency.gov/link.css"></link>
        <style>#my_header { color:red }</style>
        <h1 id="my_header">header</h1>
      HTML

      affiliate = Affiliate.create!(valid_attributes.merge(:header => tainted_header), :as => :test)
      affiliate.sanitized_header.strip.should == %q(<h1 id="my_header">header</h1>)
    end
  end

  describe "#sanitized_footer" do
    it "should remove all banned HTML elements" do
      tainted_footer = <<-HTML
        <script src="http://cdn.agency.gov/script.js"></script>
        <link href="http://cdn.agency.gov/link.css"></link>
        <style>#my_footer { color:red }</style>
        <h1 id="my_footer">footer</h1>
      HTML

      affiliate = Affiliate.create!(valid_attributes.merge(:footer => tainted_footer), :as => :test)
      affiliate.sanitized_footer.strip.should == %q(<h1 id="my_footer">footer</h1>)
    end
  end

  describe "#unused_features" do
    before do
      @affiliate = affiliates(:power_affiliate)
      @affiliate.features.delete_all
    end

    it "should return the collection of unused features for the affiliate" do
      ufs = @affiliate.unused_features
      ufs.size.should == 2
      @affiliate.features << features(:sayt)
      ufs = @affiliate.unused_features
      ufs.size.should == 1
      ufs.first.should == features(:disco)
    end
  end

  describe '#last_month_query_count' do
    let(:count_query) { mock('CountQuery', body: 'any body') }

    before do
      Date.stub(:current).and_return(Date.new(2014, 4, 1))
    end

    it 'returns previous month filtered search count from human-logstash-* indexes' do
      affiliate = affiliates(:power_affiliate)
      CountQuery.should_receive(:new).with(affiliate.name).and_return count_query
      RtuCount.should_receive(:count).with("human-logstash-2014.03.*", 'search', count_query.body).and_return(88)
      affiliate.last_month_query_count.should == 88
    end
  end

  describe '#user_emails' do
    it 'returns comma delimited user emails' do
      affiliate = affiliates(:non_existent_affiliate)
      affiliate.user_emails.should == 'Another Manager <another_affiliate_manager@fixtures.org>,Pending Email Verification Affiliate Manager <affiliate_manager_with_pending_email_verification_status@fixtures.org>'
    end
  end

  describe '#mobile_logo_url' do
    it 'returns mobile logo url' do
      mobile_logo_url = 'http://link.to/mobile_logo.png'.freeze
      mobile_logo = mock('mobile logo')
      affiliate = affiliates(:power_affiliate)
      affiliate.should_receive(:mobile_logo_file_name).and_return('mobile_logo.png')
      affiliate.should_receive(:mobile_logo).and_return(mobile_logo)
      mobile_logo.should_receive(:url).and_return(mobile_logo_url)

      affiliate.mobile_logo_url.should == mobile_logo_url
    end
  end

  describe '#header_image_url' do
    it 'returns header image url' do
      header_image_url = 'http://link.to/header_image.png'.freeze
      header_image = mock('header image')
      affiliate = affiliates(:power_affiliate)
      affiliate.should_receive(:header_image_file_name).and_return('header_image.png')
      affiliate.should_receive(:header_image).and_return(header_image)
      header_image.should_receive(:url).and_return(header_image_url)

      affiliate.header_image_url.should == header_image_url
    end
  end

  describe '#assign_sitelink_generator_names!' do
    it 'assigns sitelink generator names' do
      sitelink_generator_names = %w(SitelinkGenerator::FakeGenerator).freeze
      SitelinkGeneratorUtils.should_receive(:matching_generator_names).
        with(%w(sec.gov)).
        and_return(sitelink_generator_names)

      affiliate = affiliates(:power_affiliate)
      affiliate.site_domains.create!(domain: 'sec.gov')
      affiliate.assign_sitelink_generator_names!
      affiliate.sitelink_generator_names.should eq(sitelink_generator_names)
    end
  end

  describe '#excludes_url?' do
    it 'excludes encoded URL' do
      affiliate = affiliates(:power_affiliate)
      url = 'http://www.example.gov/with%20spaces%20url.doc'.freeze
      affiliate.excluded_urls.create!(url: url)
      expect(affiliate.excludes_url?(url)).to be_true
    end
  end

  describe '#header_tagline_font_family=' do
    it 'should assign header tagline font family' do
      affiliate = affiliates(:power_affiliate)
      affiliate.header_tagline_font_family = 'Verdana, sans-serif'
      affiliate.save!
      expect(affiliate.header_tagline_font_family).to eq('Verdana, sans-serif')
    end
  end

  describe '#header_tagline_font_size=' do
    it 'should nullify blank value' do
      affiliate = affiliates(:power_affiliate)
      affiliate.header_tagline_font_size = ' '
      affiliate.save!
      expect(affiliate.header_tagline_font_size).to be_nil
    end
  end

  describe '#header_tagline_font_style=' do
    it 'should assign header tagline font style' do
      affiliate = affiliates(:power_affiliate)
      affiliate.header_tagline_font_style = 'normal'
      affiliate.save!
      expect(affiliate.header_tagline_font_style).to eq('normal')
    end
  end

  describe "#should_show_job_organization_name?" do
    let(:affiliate) { affiliates(:basic_affiliate) }

    context 'when agency is blank' do
      it 'should return true' do
        affiliate.should_show_job_organization_name?.should be_true
      end
    end

    context 'when agency has no org codes' do
      before do
        agency = Agency.create!(name: "National Park Service", abbreviation: "NPS")
        affiliate.agency = agency
      end

      it 'should return true' do
        affiliate.should_show_job_organization_name?.should be_true
      end
    end

    context 'when agency org codes are all department level' do
      before do
        agency = Agency.create!(name: "National Park Service", abbreviation: "NPS")
        AgencyOrganizationCode.create!(organization_code: "GS", agency: agency)
        affiliate.agency = agency
      end

      it 'should return true' do
        affiliate.should_show_job_organization_name?.should be_true
      end
    end

    context 'when only some agency org codes are department level' do
      before do
        agency = Agency.create!(name: "National Park Service", abbreviation: "NPS")
        AgencyOrganizationCode.create!(organization_code: "GS", agency: agency)
        AgencyOrganizationCode.create!(organization_code: "AF", agency: agency)
        AgencyOrganizationCode.create!(organization_code: "USMI", agency: agency)
        affiliate.agency = agency
      end

      it 'should return false' do
        affiliate.should_show_job_organization_name?.should be_false
      end
    end
  end

  describe "#default_autodiscovery_url" do
    let(:site_domains_attributes) { nil }
    let(:single_domain) { { '0' => { domain: 'usa.gov' } } }
    let(:multiple_domains) { single_domain.merge({ '1' => { domain: 'navy.mil' } }) }

    subject do
      attrs = valid_create_attributes.dup.merge({
        website: website,
        site_domains_attributes: site_domains_attributes,
      }).reject { |k,v| v.nil? }
      Affiliate.create!(attrs)
    end

    context "when the website is empty" do
      let(:website) { nil }
      its(:default_autodiscovery_url) { should be_nil }

      context "when a single site_domain is provided" do
        let(:site_domains_attributes) { single_domain }
        its(:default_autodiscovery_url) { should eq('http://usa.gov') }
      end

      context "when mutiple site_domains are provided" do
        let(:site_domains_attributes) { multiple_domains }
        its(:default_autodiscovery_url) { should be_nil }
      end
    end

    context "when the website is present" do
      let(:website) { valid_create_attributes[:website] }
      its(:default_autodiscovery_url) { should eq(website) }

      context "when a single site_domain is provided" do
        let(:site_domains_attributes) { single_domain }
        its(:default_autodiscovery_url) { should eq(website) }
      end

      context "when mutiple site_domains are provided" do
        let(:site_domains_attributes) { multiple_domains }
        its(:default_autodiscovery_url) { should eq(website) }
      end
    end
  end

  describe "#enable_video_govbox!" do
    let(:affiliate) { affiliates(:gobiernousa_affiliate) }
    before do
      youtube_profile = youtube_profiles(:whitehouse)
      affiliate.youtube_profiles << youtube_profile
      affiliate.enable_video_govbox!
    end

    it 'should localize "Videos" for the name of the RSS feed' do
      affiliate.rss_feeds.last.name.should == "Vídeos"
    end
  end

  describe '#dup' do
    let(:original_instance) do
      css_property_hash = {
        'title_link_color' => '#33ff33',
        'visited_title_link_color' => '#0000ff'
      }
      site = Affiliate.create!(css_property_hash: css_property_hash,
                               display_name: 'original site',
                               header_tagline_logo_content_type: 'image/jpeg',
                               header_tagline_logo_file_name: 'test.jpg',
                               header_tagline_logo_file_size: 100,
                               header_tagline_logo_updated_at: DateTime.current,
                               mobile_logo_content_type: 'image/jpeg',
                               mobile_logo_file_name: 'test.jpg',
                               mobile_logo_file_size: 100,
                               mobile_logo_updated_at: DateTime.current,
                               name: 'original-site',
                               nutshell_id: 888,
                               page_background_image_content_type: 'image/jpeg',
                               page_background_image_file_name: 'test.jpg',
                               page_background_image_file_size: 100,
                               page_background_image_updated_at: DateTime.current,
                               theme: 'custom')
      Affiliate.find site.id
    end

    include_examples 'dupable',
                     %w(api_access_key
                        header_tagline_logo_content_type
                        header_tagline_logo_file_name
                        header_tagline_logo_file_size
                        header_tagline_logo_updated_at
                        mobile_logo_content_type
                        mobile_logo_file_name
                        mobile_logo_file_size
                        mobile_logo_updated_at
                        name
                        nutshell_id
                        page_background_image_content_type
                        page_background_image_file_name
                        page_background_image_file_size
                        page_background_image_updated_at)

    it 'sets @css_property_hash instance variable' do
      expect(subject.instance_variable_get(:@css_property_hash)).to include(:title_link_color, :visited_title_link_color)
    end
  end

  describe '#update_template' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:template) { affiliate_templates(:usagov_classic)}
    let(:template_rounded) { affiliate_templates(:usagov_rounded_header_link)}

    it "sets the affiliate belongs_to template relationship by 'type'" do
      affiliate.affiliate_templates.find_by_template_class("Template::RoundedHeaderLink").update_attribute(:available, true)
      expect(affiliate.affiliate_template.template_class).to eq "Template::Classic"
      affiliate.update_template("Template::RoundedHeaderLink")
      expect(affiliate.affiliate_template.template_class).to eq "Template::RoundedHeaderLink"
    end

    it "errors if it is 'not a available template' for this Affiliate" do
      expect(affiliate.update_template("Template::NonExistant")).to be false
    end

    it "errors if it is 'not a selected template' for this Affiliate" do
      template = affiliate.affiliate_templates.find_by_template_class("Template::RoundedHeaderLink")
      template.update_attribute(:available, false)

      expect(affiliate.update_template("Template::RoundedHeaderLink")).to be false
    end

  end

  describe 'has_many :affiliate_templates' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:template_rounded) { affiliate_templates(:usagov_rounded_header_link)}

    describe '#find_and_activate_or_create_template(type)' do
      it "receives type and creates the template if it does not exist" do
        affiliate.affiliate_templates.destroy_all
        expect(affiliate.affiliate_templates.map(&:template_class)).not_to include "Template::RoundedHeaderLink"
        affiliate.affiliate_templates.find_and_activate_or_create_template("Template::RoundedHeaderLink")
        affiliate.reload
        expect(affiliate.affiliate_templates.map(&:template_class)).to include "Template::RoundedHeaderLink"
      end

      it "receives type and re-activates the template if it exist" do
        expect(affiliate.affiliate_templates.find_by_template_class("Template::RoundedHeaderLink").available).to eq false
        affiliate.affiliate_templates.find_and_activate_or_create_template("Template::RoundedHeaderLink")
        expect(affiliate.affiliate_templates.find_by_template_class("Template::RoundedHeaderLink").available).to eq true
      end
    end

    describe '#activate(template_types)' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it "calls find_and_activate_or_create_template for all template types" do
        template_types = ["Template::Classic", "Template::RoundedHeaderLink"]
        affiliate.affiliate_templates.should_receive(:find_and_activate_or_create_template).with("Template::Classic")
        affiliate.affiliate_templates.should_receive(:find_and_activate_or_create_template).with("Template::RoundedHeaderLink")
        affiliate.affiliate_templates.make_available(template_types)
      end
    end

    describe 'deactivate(template_types)' do
      let(:affiliate) { affiliates(:usagov_affiliate) }
      let(:template_rounded) { affiliate_templates(:usagov_rounded_header_link)}
      let(:template_classic) { affiliate_templates(:usagov_classic)}

      it "deactivates provided template types by changing the available value to false" do
        template_types = ["Template::RoundedHeaderLink"]
        template_rounded.update_attribute(:available, true)
        affiliate.affiliate_templates.make_unavailable(template_types)
        template_rounded.reload
        expect(template_rounded.available).to eq false
      end

      it "adds a ActiveRecord error to Affiliate and returns false if deactivating the selected Template" do
        template_types = ["Template::Classic"]
        expect(affiliate.affiliate_template.template_class).to eq "Template::Classic"
        affiliate.affiliate_templates.make_unavailable(template_types)
        expect(affiliate.errors.count).to eq 1
        expect(affiliate.affiliate_template.template_class).to eq "Template::Classic"
      end
    end

    describe "#load_template_schema" do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it "loads the templates Schema if no schema is stored in DB" do
        p affiliate.affiliate_template
        expect(affiliate.load_template_schema.to_json).to eq(affiliate.affiliate_template.template_class.constantize::DEFAULT_TEMPLATE_SCHEMA.to_json)
      end

      it "loads the saved Schema if stored in DB" do
        changed_to_schema = {"css" => "Test Schema"}.to_json
        affiliate.update_attribute(:template_schema, changed_to_schema)
        affiliate.reload
        expect(affiliate.load_template_schema.to_json).to eq(changed_to_schema)
      end
    end

    describe "#save_template_schema" do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it "merges defaults and saves the schema" do
        stub_const("Template::DEFAULT_TEMPLATE_SCHEMA", {"schema" => {"default" => "default" }})
        affiliate.affiliate_template
        affiliate.save_template_schema({ "schema" => {"test_schema" => "test"}})
        expect(affiliate.load_template_schema).to eq(Hashie::Mash.new({"schema"=>{"default"=>"default", "test_schema"=>"test"}}))
      end

      it "loads the schema if not blank, merges new values and saves the schema" do
        affiliate.template_schema = {"schema" => {"default" => "default" }}.to_json
        affiliate.save
        affiliate.affiliate_template
        affiliate.reload

        affiliate.save_template_schema({ "schema" => {"test_schema" => "test"}})
        expected_schema = {"schema"=>{"default"=>"default", "test_schema"=>"test"}}
        expect(affiliate.load_template_schema).to eq(expected_schema)
      end

    end

    describe "#reset_template_schema" do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it "resets the schema" do
        affiliate.affiliate_template
        affiliate.update_attribute(:template_schema, {"test" => "test"}.to_json)
        stub_const("Template::DEFAULT_TEMPLATE_SCHEMA", {"schema" => {"default" => "default" }})
        expect(affiliate.reset_template_schema).to eq(Hashie::Mash.new({"schema"=>{"default"=>"default"}}))
      end
    end

     describe "#port_classic_theme" do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it "merges existing colors into template_schema" do
        affiliate.affiliate_template
        affiliate.update_attributes({
          "css_property_hash"=>{
          "header_tagline_font_size"=>nil,
          "content_background_color"=>"#FFFFFF",
          "content_border_color"=>"#CACACA",
          "content_box_shadow_color"=>"#555555",
          "description_text_color"=>"#000000",
          "footer_background_color"=>"#DFDFDF",
          "footer_links_text_color"=>"#000000",
          "header_links_background_color"=>"#0068c4",
          "header_links_text_color"=>"#fff",
          "header_text_color"=>"#000000",
          "header_background_color"=>"#FFFFFF",
          "header_tagline_background_color"=>"#000000",
          "header_tagline_color"=>"#FFFFFF",
          "search_button_text_color"=>"#FFFFFF",
          "search_button_background_color"=>"#00396F",
          "left_tab_text_color"=>"#9E3030",
          "navigation_background_color"=>"#F1F1F1",
          "navigation_link_color"=>"#505050",
          "page_background_color"=>"#99999",
          "title_link_color"=>"#2200CC",
          "url_link_color"=>"#006800",
          "visited_title_link_color"=>"#800080",
          "font_family"=>"Arial, sans-serif",
          "header_tagline_font_family"=>"Georgia, \"Times New Roman\", serif",
          "header_tagline_font_style"=>"italic"},
          "theme"=>"custom"
        })
        affiliate.port_classic_theme

        expect(affiliate.load_template_schema.css.colors.header.header_text_color).to eq "#000000"

      end
    end
  end

  describe 'image assets' do
    let(:image) { File.open(Rails.root.join('spec/fixtures/images/corgi.jpg')) }
    let(:image_attributes) do
      %i{ page_background_image header_image mobile_logo header_tagline_logo }
    end
    let(:images) do
      { page_background_image: image,
        header_image:          image,
        mobile_logo:           image,
        header_tagline_logo:   image }
    end
    let(:affiliate) do
      Affiliate.create(valid_create_attributes.merge(images))
    end

    it 'stores the images in s3 with a secure url' do
      image_attributes.each do |image|
        expect(affiliate.send(image).url).to match /https:\/\/***REMOVED***\.s3\.amazonaws\.com\/test\/site\/#{affiliate.id}\/#{image}\/\d+\/original\/corgi.jpg/

      end
    end
  end
end
