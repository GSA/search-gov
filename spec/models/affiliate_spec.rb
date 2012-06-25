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
    ["<IMG SRC=", "259771935505'", "spacey name"].each do |value|
      it { should_not allow_value(value).for(:name) }
    end
    %w{data.gov ct-new some_aff 123 NewAff}.each do |value|
      it { should allow_value(value).for(:name) }
    end
    it { should have_and_belong_to_many :users }
    it { should have_many :boosted_contents }
    it { should have_many :sayt_suggestions }
    it { should have_many(:featured_collections).dependent(:destroy) }
    it { should have_many(:affiliate_feature_addition).dependent(:destroy) }
    it { should have_many(:features) }
    it { should have_many(:rss_feeds).dependent(:destroy) }
    it { should have_many(:site_domains).dependent(:destroy) }
    it { should have_many(:indexed_domains).dependent(:destroy) }
    it { should have_many(:daily_left_nav_stats).dependent(:destroy) }
    it { should belong_to :affiliate_template }
    it { should belong_to :staged_affiliate_template }
    it { should have_and_belong_to_many :twitter_profiles }
    it { should_not allow_mass_assignment_of(:name) }
    it { should_not allow_mass_assignment_of(:uses_one_serp) }
    it { should_not allow_mass_assignment_of(:previous_fields_json) }
    it { should_not allow_mass_assignment_of(:live_fields_json) }
    it { should_not allow_mass_assignment_of(:staged_fields_json) }
    it { should validate_attachment_content_type(:page_background_image).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }
    it { should validate_attachment_content_type(:staged_page_background_image).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }
    it { should validate_attachment_content_type(:header_image).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }
    it { should validate_attachment_content_type(:staged_header_image).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }

    it "should create a new instance given valid attributes" do
      Affiliate.create!(@valid_create_attributes)
    end

    it "should generate Site Handle based on display name" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "Affiliate site"))
      affiliate.name.should == "affiliatesite"
    end

    it "should downcase the name if it's uppercase" do
      affiliate = Affiliate.new(@valid_create_attributes)
      affiliate.name = 'AffiliateSite'
      affiliate.save!
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
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:locale => 'en'))
        affiliate.search_results_page_title.should == '{Query} - {SiteName} Search Results'

        affiliate = Affiliate.create!(@valid_create_attributes)
        affiliate.search_results_page_title.should == '{Query} - {SiteName} resultados de la búsqueda'
      end

      it "should set default staged_search_results_page_title if staged_search_results_page_title is blank" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:locale => 'en'))
        affiliate.staged_search_results_page_title.should == '{Query} - {SiteName} Search Results'

        affiliate = Affiliate.create!(@valid_create_attributes)
        affiliate.staged_search_results_page_title.should == '{Query} - {SiteName} resultados de la búsqueda'
      end

      it "should update css_properties with json string from css property hash" do
        css_property_hash = {'title_link_color' => '#33ff33', 'visited_title_link_color' => '#0000ff'}
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:css_property_hash => css_property_hash))
        JSON.parse(affiliate.css_properties, :symbolize_keys => true)[:title_link_color].should == '#33ff33'
        JSON.parse(affiliate.css_properties, :symbolize_keys => true)[:visited_title_link_color].should == '#0000ff'
      end

      it "should update staged_css_properties with json string from staged_css property hash" do
        staged_css_property_hash = {'title_link_color' => '#33ff33', 'visited_title_link_color' => '#0000ff'}
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:staged_css_property_hash => staged_css_property_hash))
        JSON.parse(affiliate.staged_css_properties, :symbolize_keys => true)[:title_link_color].should == '#33ff33'
        JSON.parse(affiliate.staged_css_properties, :symbolize_keys => true)[:visited_title_link_color].should == '#0000ff'
      end

      it "should set uses_one_serp column by default if it is not set" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:staged_theme => 'elegant'))
        affiliate.uses_one_serp?.should be_true
      end

      it "should not set uses_one_serp if it's already set" do
        affiliate = Affiliate.new(@valid_create_attributes)
        affiliate.uses_one_serp = false
        affiliate.save!
        affiliate.uses_one_serp?.should be_false
      end

      it "should normalize site domains" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(
                                        :site_domains_attributes => {'0' => {:domain => 'www1.usa.gov'},
                                                                     '1' => {:domain => 'www2.usa.gov'},
                                                                     '2' => {:domain => 'usa.gov'}}))
        affiliate.site_domains(true).count.should == 1
        affiliate.site_domains.first.domain.should == 'usa.gov'
      end

      it "should default the govbox fields to OFF" do
        affiliate = Affiliate.create!(@valid_create_attributes)
        affiliate.is_agency_govbox_enabled.should == false
        affiliate.is_medline_govbox_enabled.should == false
      end

      it "should have SAYT enabled by default" do
        Affiliate.create!(@valid_create_attributes).is_sayt_enabled.should be_true
      end

      it "should generate a database-level error when attempting to add an affiliate with the same name as an existing affiliate, but with different case; instead it should return false" do
        affiliate = Affiliate.new(@valid_attributes)
        affiliate.name = @valid_attributes[:name]
        affiliate.save!
        duplicate_affiliate = Affiliate.new(@valid_attributes)
        duplicate_affiliate.name = @valid_attributes[:name].upcase
        duplicate_affiliate.save.should be_false
      end

      it "should populate default search label for English site" do
        affiliate = Affiliate.create!(@valid_attributes.merge(:locale => 'en'))
        affiliate.default_search_label.should == 'Everything'
      end

      it "should populate default search labels for Spanish site" do
        affiliate = Affiliate.create!(@valid_attributes.merge(:locale => 'es'))
        affiliate.default_search_label.should == 'Todo'
      end
    end
  end

  describe "on save" do
    let(:affiliate) { Affiliate.create!(@valid_create_attributes) }

    it "should set staged_uses_one_serp to true if uses_one_serp is true" do
      affiliate.uses_one_serp = true
      affiliate.staged_uses_one_serp = nil
      affiliate.save!
      affiliate.staged_uses_one_serp.should be_true
    end

    it "should set staged_uses_one_serp to false if uses_one_serp is false" do
      affiliate.uses_one_serp = false
      affiliate.staged_uses_one_serp = nil
      affiliate.save!
      affiliate.staged_uses_one_serp.should be_false
    end

    it "should set theme columns by default" do
      affiliate.theme = nil
      affiliate.staged_theme = nil
      affiliate.save!
      affiliate.theme.should == 'default'
      affiliate.staged_theme.should == 'default'
    end

    it "should set managed header text fields to display_name if the current values are nil" do
      affiliate.display_name = 'my agency'
      affiliate.managed_header_text = nil
      affiliate.staged_managed_header_text = nil
      affiliate.save!
      affiliate.managed_header_text.should == 'my agency'
      affiliate.staged_managed_header_text.should == 'my agency'
    end

    it "should not set managed header text fields to display_name if the current values are blank but not nil" do
      affiliate.display_name = 'my agency'
      affiliate.managed_header_text = '  '
      affiliate.staged_managed_header_text = '  '
      affiliate.save!
      affiliate.managed_header_text.should be_blank
      affiliate.staged_managed_header_text.should be_blank
    end

    it "should set managed_header_css_properties if the affiliate uses_managed_header_footer" do
      affiliate.theme = 'elegant'
      affiliate.managed_header_css_properties = nil
      affiliate.uses_managed_header_footer = true

      affiliate.staged_theme = 'fun_blue'
      affiliate.staged_uses_managed_header_footer = true
      affiliate.staged_managed_header_css_properties = nil

      affiliate.save!

      affiliate.managed_header_css_properties[:header_background_color].should == Affiliate::THEMES[:elegant][:search_button_background_color]
      affiliate.managed_header_css_properties[:header_text_color].should == Affiliate::THEMES[:elegant][:search_button_text_color]
      affiliate.managed_header_css_properties[:header_footer_link_color].should == Affiliate::THEMES[:elegant][:search_button_background_color]
      affiliate.managed_header_css_properties[:header_footer_link_background_color].should == Affiliate::THEMES[:elegant][:search_button_text_color]
      affiliate.staged_managed_header_css_properties[:header_background_color].should == Affiliate::THEMES[:fun_blue][:search_button_background_color]
      affiliate.staged_managed_header_css_properties[:header_text_color].should == Affiliate::THEMES[:fun_blue][:search_button_text_color]
      affiliate.staged_managed_header_css_properties[:header_footer_link_color].should == Affiliate::THEMES[:fun_blue][:search_button_background_color]
      affiliate.staged_managed_header_css_properties[:header_footer_link_background_color].should == Affiliate::THEMES[:fun_blue][:search_button_text_color]
    end

    it "should set default header_footer_link_color and header_footer_link_background_color" do
      affiliate.theme = 'elegant'
      affiliate.uses_managed_header_footer = true
      affiliate.staged_theme = 'fun_blue'
      affiliate.staged_uses_managed_header_footer = true
      affiliate.managed_header_css_properties[:header_footer_link_color] = ''
      affiliate.managed_header_css_properties[:header_footer_link_background_color] = ''
      affiliate.staged_managed_header_css_properties[:header_footer_link_color] = ''
      affiliate.staged_managed_header_css_properties[:header_footer_link_background_color] = ''
      affiliate.save!

      affiliate.managed_header_css_properties[:header_footer_link_color].should == Affiliate::THEMES[:elegant][:search_button_background_color]
      affiliate.managed_header_css_properties[:header_footer_link_background_color].should == Affiliate::THEMES[:elegant][:search_button_text_color]
      affiliate.staged_managed_header_css_properties[:header_footer_link_color].should == Affiliate::THEMES[:fun_blue][:search_button_background_color]
      affiliate.staged_managed_header_css_properties[:header_footer_link_background_color].should == Affiliate::THEMES[:fun_blue][:search_button_text_color]
    end

    it "should not override non custom theme attributes" do
      affiliate.theme = 'elegant'
      affiliate.css_property_hash = {:page_background_color => '#FFFFFF'}
      affiliate.staged_theme = 'fun_blue'
      affiliate.staged_css_property_hash = {:page_background_color => '#FFFFFF'}
      affiliate.save!
      Affiliate.find(affiliate.id).css_property_hash[:page_background_color].should == Affiliate::THEMES[:elegant][:page_background_color]
      Affiliate.find(affiliate.id).staged_css_property_hash[:page_background_color].should == Affiliate::THEMES[:fun_blue][:page_background_color]
    end

    it "should set default affiliate template" do
      affiliate.affiliate_template_id = nil
      affiliate.staged_affiliate_template_id = nil
      affiliate.save!
      Affiliate.find(affiliate.id).affiliate_template_id.should == AffiliateTemplate.default_id
      Affiliate.find(affiliate.id).staged_affiliate_template_id.should == AffiliateTemplate.default_id
    end

    it "should save staged favicon URL with http:// prefix when it does not start with http(s)://" do
      url = 'cdn.agency.gov/staged_favicon.ico'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        affiliate.update_attributes!(:staged_favicon_url => "#{prefix}#{url}")
        affiliate.staged_favicon_url.should == "http://#{prefix}#{url}"
      end
    end

    it "should save staged favicon URL as is when it starts with http(s)://" do
      url = 'cdn.agency.gov/staged_favicon.ico'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        affiliate.update_attributes(:staged_favicon_url => "#{prefix}#{url}")
        affiliate.staged_favicon_url.should == "#{prefix}#{url}"
      end
    end

    it "should save staged external CSS URL with http:// prefix when it does not start with http(s)://" do
      url = 'cdn.agency.gov/custom.css'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        affiliate.update_attributes!(:staged_external_css_url => "#{prefix}#{url}")
        affiliate.staged_external_css_url.should == "http://#{prefix}#{url}"
      end
    end

    it "should save staged external CSS URL as is when it starts with http(s)://" do
      url = 'cdn.agency.gov/custom.css'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        affiliate.update_attributes!(:staged_external_css_url => "#{prefix}#{url}")
        affiliate.staged_external_css_url.should == "#{prefix}#{url}"
      end
    end

    it "should set css properties" do
      affiliate.css_property_hash = {:font_family => 'Verdana, sans-serif'}
      affiliate.staged_css_property_hash = {:font_family => 'Georgia, serif'}
      affiliate.save!
      Affiliate.find(affiliate.id).css_property_hash[:font_family].should == 'Verdana, sans-serif'
      Affiliate.find(affiliate.id).staged_css_property_hash[:font_family].should == 'Georgia, serif'
    end

    it "should set header_footer_nested_css fields" do
      affiliate.update_attributes!(:staged_header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }', :header_footer_css => '')
      affiliate.staged_nested_header_footer_css.squish.should =~ /^#{Regexp.escape('.header-footer h1{color:blue}')}$/
      affiliate.header_footer_css.should be_blank
      affiliate.update_attributes!(:staged_header_footer_css => '', :header_footer_css => '@charset "UTF-8"; @import url("other.css"); live.h1 { color: red }')
      affiliate.staged_nested_header_footer_css.should be_blank
      affiliate.nested_header_footer_css.squish.should =~ /^#{Regexp.escape('.header-footer live.h1{color:red}')}$/
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

    it "should set staged_managed_header_links" do
      staged_managed_header_links_attributes = {"0" => {:position => '1', :title => 'Blog', :url => 'http://blog.agency.gov'},
                                                "1" => {:position => '0', :title => 'News', :url => 'http://news.agency.gov'},
                                                "2" => {:position => '2', :title => 'Services', :url => 'http://services.agency.gov'}}
      affiliate.update_attributes!(:staged_managed_header_links_attributes => staged_managed_header_links_attributes)
      affiliate.staged_managed_header_links.should == [{:position => 0, :title => 'News', :url => 'http://news.agency.gov'},
                                                       {:position => 1, :title => 'Blog', :url => 'http://blog.agency.gov'},
                                                       {:position => 2, :title => 'Services', :url => 'http://services.agency.gov'}]
    end

    it "should set staged_managed_footer_links" do
      staged_managed_footer_links_attributes = {"0" => {:position => '1', :title => 'About Us', :url => 'http://about.agency.gov'},
                                                "1" => {:position => '0', :title => 'Home', :url => 'http://www.agency.gov'},
                                                "2" => {:position => '2', :title => 'Contact Us', :url => 'http://contact.agency.gov'}}
      affiliate.update_attributes!(:staged_managed_footer_links_attributes => staged_managed_footer_links_attributes)
      affiliate.staged_managed_footer_links.should == [{:position => 0, :title => 'Home', :url => 'http://www.agency.gov'},
                                                       {:position => 1, :title => 'About Us', :url => 'http://about.agency.gov'},
                                                       {:position => 2, :title => 'Contact Us', :url => 'http://contact.agency.gov'}]
    end

    context "when there is an existing staged page background image" do
      let(:staged_page_background_image) { mock('staged page background image') }

      before do
        affiliate.should_receive(:staged_page_background_image?).and_return(true)
        affiliate.should_receive(:staged_page_background_image).at_least(:once).and_return(staged_page_background_image)
      end

      context "when marking an existing staged page background image for deletion" do
        it "should clear existing staged page background image" do
          staged_page_background_image.should_receive(:dirty?).and_return(false)
          staged_page_background_image.should_receive(:clear)
          affiliate.update_attributes!(:mark_staged_page_background_image_for_deletion => '1')
        end
      end

      context "when uploading a new staged page background image" do
        it "should not clear the existing staged page background image" do
          staged_page_background_image.should_receive(:dirty?).and_return(true)
          staged_page_background_image.should_not_receive(:clear)
          affiliate.update_attributes!(@update_params)
        end
      end
    end

    context "when there is an existing staged header image" do
      let(:staged_header_image) { mock('staged header image') }

      before do
        affiliate.should_receive(:staged_header_image?).and_return(true)
        affiliate.should_receive(:staged_header_image).at_least(:once).and_return(staged_header_image)
      end

      context "when marking an existing staged header image for deletion" do
        it "should clear existing image" do
          staged_header_image.should_receive(:dirty?).and_return(false)
          staged_header_image.should_receive(:clear)
          affiliate.update_attributes!(:mark_staged_header_image_for_deletion => '1')
        end
      end

      context "when uploading a new staged header image" do
        it "should not clear the existing staged header image" do
          staged_header_image.should_receive(:dirty?).and_return(true)
          staged_header_image.should_not_receive(:clear)
          affiliate.update_attributes!(@update_params)
        end
      end
    end

    it "should populate search labels for English site" do
      english_affiliate = Affiliate.create!(@valid_attributes.merge(:locale => 'en'))
      english_affiliate.default_search_label = ''
      english_affiliate.save!
      english_affiliate.default_search_label.should == 'Everything'
    end

    it "should populate search labels for Spanish site" do
      spanish_affiliate = Affiliate.create!(@valid_attributes.merge(:locale => 'es'))
      spanish_affiliate.default_search_label = ''
      spanish_affiliate.save!
      spanish_affiliate.default_search_label.should == 'Todo'
    end

    it "should strip text columns" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.update_attributes!(:facebook_handle => '     http://www.facebook.com/WhiteHouse   ',
                                   :flickr_url => '   http://www.flickr.com/photos/whitehouse   ',
                                   :twitter_handle => '     whitehouse   ',
                                   :youtube_handles => ['     whitehouse   ', '  USGovernment ', ' whitehouse '],
                                   :ga_web_property_id => '  WEB_PROPERTY_ID  ')
      affiliate.facebook_handle.should == 'http://www.facebook.com/WhiteHouse'
      affiliate.flickr_url.should == 'http://www.flickr.com/photos/whitehouse'
      affiliate.twitter_handle.should == 'whitehouse'
      affiliate.youtube_handles.should == %w(USGovernment whitehouse)
      affiliate.ga_web_property_id.should == 'WEB_PROPERTY_ID'
    end

    context "on oneserp site" do
      it "should remove comments from staged_header and staged_footer fields" do
        affiliate = Affiliate.create!(@valid_create_attributes)
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
    end

    context "on legacy_template site" do
      it "should not remove comments from staged_header and staged_footer fields" do
        affiliate = Affiliate.new(@valid_create_attributes)
        affiliate.uses_one_serp = false
        affiliate.save!
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
        affiliate.update_attributes!(:staged_header => html_with_comments, :staged_footer => html_with_comments)
        Affiliate.find(affiliate.id).staged_header.should == html_with_comments
        Affiliate.find(affiliate.id).staged_footer.should == html_with_comments
      end
    end

    it "should ignore rss_feeds_attributes with blank name or blank rss_feed_urls_attributes" do
      rss_feed_content = File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
      Kernel.should_receive(:open).with('http://usasearch.howto.gov/rss').and_return(rss_feed_content)

      rss_feeds_attributes = { '0' => { :name => '', :rss_feed_urls_attributes => { '0' => { :url => '' } } },
                               '1' => { :name => 'Blog', :rss_feed_urls_attributes => { '0' => { :url => 'http://usasearch.howto.gov/rss' } } } }
      affiliate = Affiliate.create!(:display_name => 'site with blank RSS Feed')
      affiliate.update_attributes(:rss_feeds_attributes => rss_feeds_attributes).should be_true
      affiliate.rss_feeds.count.should == 1
      affiliate.rss_feeds.first.name.should == 'Blog'
      affiliate.rss_feeds.first.rss_feed_urls.first.url.should == 'http://usasearch.howto.gov/rss'
    end
  end

  describe "on destroy" do
    let(:affiliate) { Affiliate.create!(:display_name => 'connecting affiliate') }
    let(:connected_affiliate) { Affiliate.create!(:display_name => 'connected affiliate') }

    it "should destroy connection" do
      affiliate.connections.create!(:connected_affiliate => connected_affiliate, :label => 'search connected affiliate')
      Affiliate.find(affiliate.id).connections.count.should == 1
      connected_affiliate.destroy
      Affiliate.find(affiliate.id).connections.count.should == 0
    end
  end

  describe "validations" do
    it "should validate presence of :search_results_page_title on update" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.update_attributes(:search_results_page_title => "").should_not be_true
    end

    it "should validate presence of :staged_search_results_page_title on update" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.update_attributes(:staged_search_results_page_title => "").should_not be_true
    end

    it "should be valid when FONT_FAMILIES includes font_family in css property hash" do
      Affiliate::FONT_FAMILIES.each do |font_family|
        Affiliate.new(@valid_create_attributes.merge(:css_property_hash => {'font_family' => font_family})).should be_valid
      end
    end

    it "should not be valid when FONT_FAMILIES does not include font_family in css property hash" do
      Affiliate.new(@valid_create_attributes.merge(:css_property_hash => {'font_family' => 'Comic Sans MS'})).should_not be_valid
    end

    it "should be valid when color property in css property hash consists of a # character followed by 3 or 6 hexadecimal digits " do
      %w{ #333 #FFF #fff #12F #666666 #666FFF #FFFfff #ffffff }.each do |valid_color|
        css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({'left_tab_text_color' => "#{valid_color}",
                                                                          'title_link_color' => "#{valid_color}",
                                                                          'visited_title_link_color' => "#{valid_color}",
                                                                          'description_text_color' => "#{valid_color}",
                                                                          'url_link_color' => "#{valid_color}"})
        Affiliate.new(@valid_create_attributes.merge(:css_property_hash => css_property_hash)).should be_valid
      end
    end

    it "should be invalid when color property in css property hash does not consist of a # character followed by 3 or 6 hexadecimal digits " do
      %w{ 333 invalid #err #1 #22 #4444 #55555 ffffff 1 22 4444 55555 666666 }.each do |invalid_color|
        css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({'left_tab_text_color' => "#{invalid_color}",
                                                                          'title_link_color' => "#{invalid_color}",
                                                                          'visited_title_link_color' => "#{invalid_color}",
                                                                          'description_text_color' => "#{invalid_color}",
                                                                          'url_link_color' => "#{invalid_color}"})
        affiliate = Affiliate.new(@valid_create_attributes.merge(:css_property_hash => css_property_hash))
        affiliate.should_not be_valid
        affiliate.errors[:base].should include("Title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
        affiliate.errors[:base].should include("Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
        affiliate.errors[:base].should include("Description text color should consist of a # character followed by 3 or 6 hexadecimal digits")
        affiliate.errors[:base].should include("Url link color should consist of a # character followed by 3 or 6 hexadecimal digits")
      end
    end

    it "should validate color property in staged css property hash" do
      staged_css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({'title_link_color' => 'invalid', 'visited_title_link_color' => '#DDDD'})
      affiliate = Affiliate.new(@valid_create_attributes.merge(:staged_css_property_hash => staged_css_property_hash))
      affiliate.save.should be_false
      affiliate.errors[:base].should include("Title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
      affiliate.errors[:base].should include("Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
    end

    it "should validate header_footer_css" do
      affiliate = Affiliate.new(@valid_create_attributes.merge(:header_footer_css => "h1 { invalid-css-syntax }"))
      affiliate.save.should be_false
      affiliate.errors[:base].first.should match(/Invalid CSS/)

      affiliate = Affiliate.new(@valid_create_attributes.merge(:header_footer_css => "h1 { color: #DDDD }"))
      affiliate.save.should be_false
      affiliate.errors[:base].first.should match(/Colors must have either three or six digits/)
    end

    it "should validate staged_header_footer_css for invalid css property value" do
      affiliate = Affiliate.new(@valid_create_attributes.merge(:staged_header_footer_css => "h1 { invalid-css-syntax }"))
      affiliate.save.should be_false
      affiliate.errors[:base].first.should match(/Invalid CSS/)

      affiliate = Affiliate.new(@valid_create_attributes.merge(:staged_header_footer_css => "h1 { color: #DDDD }"))
      affiliate.save.should be_false
      affiliate.errors[:base].first.should match(/Colors must have either three or six digits/)
    end

    it "should validate staged_managed_header_links title" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      staged_managed_header_links_attributes = {"0" => {:position => '1', :title => '', :url => 'blog.agency.gov'},
                                                "1" => {:position => '0', :title => 'News', :url => 'http://news.agency.gov'}}
      affiliate.update_attributes(:staged_managed_header_links_attributes => staged_managed_header_links_attributes).should be_false
      affiliate.errors.count.should == 1
      affiliate.errors[:base].first.should match(/Header link title can't be blank/)
    end

    it "should validate staged_managed_header_links URL" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      staged_managed_header_links_attributes = {"0" => {:position => '1', :title => 'Blog', :url => 'blog'},
                                                "1" => {:position => '0', :title => 'News', :url => ''}}
      affiliate.update_attributes(:staged_managed_header_links_attributes => staged_managed_header_links_attributes).should be_false
      affiliate.errors.count.should == 1
      affiliate.errors[:base].last.should match(/Header link URL can't be blank/)
    end

    it "should validate staged_managed_footer_links title" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      staged_managed_footer_links_attributes = {"0" => {:position => '1', :title => '', :url => 'about.agency.gov'},
                                                "1" => {:position => '0', :title => 'Home', :url => 'http://www.agency.gov'}}
      affiliate.update_attributes(:staged_managed_footer_links_attributes => staged_managed_footer_links_attributes).should be_false
      affiliate.errors.count.should == 1
      affiliate.errors[:base].first.should match(/Footer link title can't be blank/)
    end

    it "should validate staged_managed_footer_links URL" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      staged_managed_footer_links_attributes = {"0" => {:position => '1', :title => 'About Us', :url => 'http://about.agency.gov'},
                                                "1" => {:position => '0', :title => 'Home', :url => ''}}
      affiliate.update_attributes(:staged_managed_footer_links_attributes => staged_managed_footer_links_attributes).should be_false
      affiliate.errors.count.should == 1
      affiliate.errors[:base].last.should match(/Footer link URL can't be blank/)
    end

    it "should validate the length of youtube_handles in YAML" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.youtube_handles = %w(extremesuperlong1234 extremesuperlong2345 extremesuperlong3456 extremesuperlong4567
                                     extremesuperlong5678 extremesuperlong6789 extremesuperlong7890 extremesuperlong8901
                                     extremesuperlong90ab extremesuperlong0abc extremesuperlongabcd extremesuperlongbcde)
      affiliate.save.should be_false
      affiliate.errors[:youtube_handles].should include('is too long')

      affiliate.youtube_handles = []
      20.times { affiliate.youtube_handles << 'extremesuperlong1234' }
      affiliate.save!
    end

    context "is_validate_staged_header_footer is set to true" do
      context "site uses staged one serp and staged custom header footer" do
        let(:affiliate) { Affiliate.create!(:display_name => 'test header footer validation',
                                            :uses_one_serp => true,
                                            :staged_uses_one_serp => true,
                                            :uses_managed_header_footer => false,
                                            :staged_uses_managed_header_footer => false) }
        it "should not allow script, style or link elements in staged header or staged footer" do
          header_error_message = %q(HTML to customize the top of your search results page can't contain script, style, link elements)
          footer_error_message = %q(HTML to customize the bottom of your search results page can't contain script, style, link elements)
          affiliate.is_validate_staged_header_footer = true

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
        end

        it "should not allow malformed HTML in staged header or staged footer" do
          header_error_message = 'HTML to customize the top of your search results is invalid'
          footer_error_message = 'HTML to customize the bottom of your search results is invalid'
          affiliate.is_validate_staged_header_footer = true

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
      end

      context "site uses staged one serp and staged managed header footer" do
        let(:affiliate) { Affiliate.create!(:display_name => 'test header footer validation',
                                            :uses_one_serp => true,
                                            :staged_uses_one_serp => true,
                                            :uses_managed_header_footer => true,
                                            :staged_uses_managed_header_footer => true) }

        it "should not validate staged header or staged footer on update_attributes" do
          html_with_script = <<-HTML
            <script src="http://cdn.agency.gov/script.js"></script>
            <h1>html with script</h1>
          HTML
          affiliate.update_attributes(:staged_header => html_with_script, :staged_footer => html_with_script).should be_true
        end
      end

      context "site does not use staged one serp" do
        let(:affiliate) { Affiliate.create!(:display_name => 'test header footer validation',
                                            :uses_one_serp => false,
                                            :staged_uses_one_serp => false) }

        it "should not validate staged header or staged footer on update_attributes" do
          html_with_script = <<-HTML
            <script src="http://cdn.agency.gov/script.js"></script>
            <h1>html with script</h1>
          HTML
          affiliate.update_attributes(:staged_header => html_with_script, :staged_footer => html_with_script).should be_true
        end
      end
    end

    context "is_validate_staged_header_footer is set to false" do
      let(:affiliate) { Affiliate.create!(:display_name => 'test header footer validation',
                                          :uses_one_serp => true,
                                          :staged_uses_one_serp => true,
                                          :uses_managed_header_footer => false,
                                          :staged_uses_managed_header_footer => false) }
      it "should allow script, style or link elements in staged header or staged footer" do
        affiliate.is_validate_staged_header_footer = false

        html_with_script = <<-HTML
            <script src="http://cdn.agency.gov/script.js"></script>
            <h1>html with script</h1>
        HTML
        affiliate.update_attributes(:staged_header => html_with_script, :staged_footer => html_with_script).should be_true
      end
    end

    it 'should not allow malformed external tracking code' do
      expect { Affiliate.create!(:display_name => 'a site', :external_tracking_code => '<script>malformed code;') }.to raise_error
    end
  end

  describe "#update_attributes_for_staging" do
    it "should set has_staged_content to true and receive update_attributes" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      attributes = mock('attributes')
      attributes.should_receive(:[]).with(:staged_uses_managed_header_footer).and_return('0')
      attributes.should_receive(:[]).with(:staged_page_background_image).and_return(nil)
      attributes.should_receive(:[]).with(:mark_staged_page_background_image_for_deletion).and_return(nil)
      attributes.should_receive(:[]).with(:staged_header_image).and_return(nil)
      attributes.should_receive(:[]).with(:mark_staged_header_image_for_deletion).and_return(nil)
      attributes.should_receive(:[]=).with(:has_staged_content, true)
      return_value = mock('return value')
      affiliate.should_receive(:update_attributes).with(attributes).and_return(return_value)
      affiliate.update_attributes_for_staging(attributes).should == return_value
    end

    context "when existing staged_page_background_image and page_background_image are the same" do
      let(:affiliate) { Affiliate.create!(@valid_create_attributes) }
      let(:staged_page_background_image) { mock('staged page backgroun image') }

      before do
        yesterday = Date.current.yesterday
        affiliate.staged_page_background_image_file_name = 'live_bg.gif'
        affiliate.staged_page_background_image_content_type = 'image/gif'
        affiliate.staged_page_background_image_file_size = 800
        affiliate.staged_page_background_image_updated_at = yesterday
        affiliate.page_background_image_file_name = 'live_bg.gif'
        affiliate.page_background_image_content_type = 'image/gif'
        affiliate.page_background_image_file_size = 800
        affiliate.page_background_image_updated_at = yesterday
        affiliate.save!
      end

      context "and update attributes contain new staged_page_background_image" do
        it "should destroy existing staged_page_background_image" do
          affiliate.should_receive(:staged_page_background_image_file_name=).with(nil)
          affiliate.should_receive(:staged_page_background_image_content_type=).with(nil)
          affiliate.should_receive(:staged_page_background_image_file_size=).with(nil)
          affiliate.should_receive(:staged_page_background_image_updated_at=).with(nil)
          attributes = {:staged_page_background_image => mock('new staged page background image')}
          affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

          affiliate.update_attributes_for_staging(attributes).should be_true
        end
      end

      context "and update attributes contain blank staged_page_background_image" do
        it "should not set staged_header attributes to nil" do
          affiliate.should_not_receive(:staged_page_background_image_file_name=)
          affiliate.should_not_receive(:staged_page_background_image_content_type=)
          affiliate.should_not_receive(:staged_page_background_image_file_size=)
          affiliate.should_not_receive(:staged_page_background_image_updated_at=)
          attributes = {:staged_page_background_image => ''}
          affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

          affiliate.update_attributes_for_staging(attributes).should be_true
        end
      end

      context "and update attributes contain mark_staged_page_background_image_for_deletion == '1'" do
        it "should set staged_header attributes to nil" do
          affiliate.should_receive(:staged_page_background_image_file_name=).with(nil)
          affiliate.should_receive(:staged_page_background_image_content_type=).with(nil)
          affiliate.should_receive(:staged_page_background_image_file_size=).with(nil)
          affiliate.should_receive(:staged_page_background_image_updated_at=).with(nil)
          attributes = {:mark_staged_page_background_image_for_deletion => '1'}
          affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

          affiliate.update_attributes_for_staging(attributes).should be_true
        end
      end

      context "and update attributes contain mark_staged_page_background_image_for_deletion == '0'" do
        it "should not set staged_header attributes to nil" do
          affiliate.should_not_receive(:staged_page_background_image_file_name=)
          affiliate.should_not_receive(:staged_page_background_image_content_type=)
          affiliate.should_not_receive(:staged_page_background_image_file_size=)
          affiliate.should_not_receive(:staged_page_background_image_updated_at=)
          attributes = {:mark_staged_page_background_image_for_deletion => '0'}
          affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

          affiliate.update_attributes_for_staging(attributes).should be_true
        end
      end
    end

    context "when update_attributes contain new staged_page_background_image and existing staged_page_background_image and page_background_image are different" do
      let(:affiliate) { Affiliate.create!(@valid_create_attributes) }
      let(:staged_page_background_image) { mock('staged page background image') }

      before do
        affiliate.staged_page_background_image_file_name = 'staged_bg.jpg'
        affiliate.staged_page_background_image_content_type = 'image/jpeg'
        affiliate.staged_page_background_image_file_size = 700
        affiliate.staged_page_background_image_updated_at = Time.current
        affiliate.page_background_image_file_name = 'live_bg.gif'
        affiliate.page_background_image_content_type = 'image/gif'
        affiliate.page_background_image_file_size = 800
        affiliate.page_background_image_updated_at = Time.current.yesterday
        affiliate.save!
      end

      it "should not set staged_page_background_image attributes to nil" do
        affiliate.should_not_receive(:staged_page_background_image_file_name=)
        affiliate.should_not_receive(:staged_page_background_image_content_type=)
        affiliate.should_not_receive(:staged_page_background_image_file_size=)
        affiliate.should_not_receive(:staged_page_background_image_updated_at=)
        attributes = {:staged_page_background_image => mock('new staged page background image')}
        affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

        affiliate.update_attributes_for_staging(attributes).should be_true
      end
    end

    context "when existing staged_header_image and header_image are the same" do
      let(:affiliate) { Affiliate.create!(@valid_create_attributes) }
      let(:staged_header_image) { mock('staged header image') }

      before do
        yesterday = Date.current.yesterday
        affiliate.staged_header_image_file_name = 'live.gif'
        affiliate.staged_header_image_content_type = 'image/gif'
        affiliate.staged_header_image_file_size = 800
        affiliate.staged_header_image_updated_at = yesterday
        affiliate.header_image_file_name = 'live.gif'
        affiliate.header_image_content_type = 'image/gif'
        affiliate.header_image_file_size = 800
        affiliate.header_image_updated_at = yesterday
        affiliate.save!
      end

      context "and update attributes contain new staged_header_image" do
        it "should destroy existing staged_header_image" do
          affiliate.should_receive(:staged_header_image_file_name=).with(nil)
          affiliate.should_receive(:staged_header_image_content_type=).with(nil)
          affiliate.should_receive(:staged_header_image_file_size=).with(nil)
          affiliate.should_receive(:staged_header_image_updated_at=).with(nil)
          attributes = {:staged_header_image => mock('new staged header image')}
          affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

          affiliate.update_attributes_for_staging(attributes).should be_true
        end
      end

      context "and update attributes contain blank staged_header_image" do
        it "should not set staged_header attributes to nil" do
          affiliate.should_not_receive(:staged_header_image_file_name=)
          affiliate.should_not_receive(:staged_header_image_content_type=)
          affiliate.should_not_receive(:staged_header_image_file_size=)
          affiliate.should_not_receive(:staged_header_image_updated_at=)
          attributes = {:staged_header_image => ''}
          affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

          affiliate.update_attributes_for_staging(attributes).should be_true
        end
      end

      context "and update attributes contain mark_staged_header_image_for_deletion == '1'" do
        it "should set staged_header attributes to nil" do
          affiliate.should_receive(:staged_header_image_file_name=).with(nil)
          affiliate.should_receive(:staged_header_image_content_type=).with(nil)
          affiliate.should_receive(:staged_header_image_file_size=).with(nil)
          affiliate.should_receive(:staged_header_image_updated_at=).with(nil)
          attributes = {:mark_staged_header_image_for_deletion => '1'}
          affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

          affiliate.update_attributes_for_staging(attributes).should be_true
        end
      end

      context "and update attributes contain mark_staged_header_image_for_deletion == '0'" do
        it "should not set staged_header attributes to nil" do
          affiliate.should_not_receive(:staged_header_image_file_name=)
          affiliate.should_not_receive(:staged_header_image_content_type=)
          affiliate.should_not_receive(:staged_header_image_file_size=)
          affiliate.should_not_receive(:staged_header_image_updated_at=)
          attributes = {:mark_staged_header_image_for_deletion => '0'}
          affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

          affiliate.update_attributes_for_staging(attributes).should be_true
        end
      end
    end

    context "when update_attributes contain new staged_header_image and existing staged_header_image and header_image are different" do
      let(:affiliate) { Affiliate.create!(@valid_create_attributes) }
      let(:staged_header_image) { mock('staged header image') }

      before do
        affiliate.staged_header_image_file_name = 'staged.jpg'
        affiliate.staged_header_image_content_type = 'image/jpeg'
        affiliate.staged_header_image_file_size = 700
        affiliate.staged_header_image_updated_at = Time.current
        affiliate.header_image_file_name = 'live.gif'
        affiliate.header_image_content_type = 'image/gif'
        affiliate.header_image_file_size = 800
        affiliate.header_image_updated_at = Time.current.yesterday
        affiliate.save!
      end

      it "should not set staged_header_image attributes to nil" do
        affiliate.should_not_receive(:staged_header_image_file_name=)
        affiliate.should_not_receive(:staged_header_image_content_type=)
        affiliate.should_not_receive(:staged_header_image_file_size=)
        affiliate.should_not_receive(:staged_header_image_updated_at=)
        attributes = {:staged_header_image => mock('new staged header image')}
        affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

        affiliate.update_attributes_for_staging(attributes).should be_true
      end
    end

    context "when attributes contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to true" do
        affiliate = Affiliate.create!(:display_name => 'oneserp affiliate')
        affiliate.should_receive(:is_validate_staged_header_footer=).with(true)
        affiliate.update_attributes_for_staging(:staged_uses_managed_header_footer => '0',
                                                :staged_header => 'staged header',
                                                :staged_footer => 'staged footer')
      end
    end

    context "when attributes does not contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to false" do
        affiliate = Affiliate.create!(:display_name => 'oneserp affiliate')
        affiliate.should_not_receive(:is_validate_staged_header_footer=)
        affiliate.update_attributes_for_staging(:staged_uses_managed_header_footer => '1',
                                                :staged_managed_header_home_url => 'http://usasearch.howto.gov')
      end
    end

    context "when attributes contain staged_uses_one_serp='1'" do
      it "should set is_validate_staged_header_footer to true" do
        affiliate = Affiliate.create!(:display_name => 'legacy affiliate', :uses_one_serp => false)
        affiliate.should_receive(:is_validate_staged_header_footer=).with(true)
        affiliate.update_attributes_for_staging(:staged_uses_one_serp => '1',
                                                :staged_favicon_url => 'cdn.agency.gov/staged_favicon.ico')
      end
    end

    context "when attributes contain staged_uses_one_serp='0'" do
      it "should set is_validate_staged_header_footer to false" do
        affiliate = Affiliate.create!(:display_name => 'legacy affiliate', :uses_one_serp => false)
        affiliate.should_not_receive(:is_validate_staged_header_footer=)
        affiliate.update_attributes_for_staging(:staged_uses_one_serp => '0',
                                                :staged_favicon_url => 'cdn.agency.gov/staged_favicon.ico')
      end
    end
  end

  describe "#update_attributes_for_live" do
    let(:affiliate) { Affiliate.create!(@valid_create_attributes.merge(:header => 'old header', :footer => 'old footer')) }

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
    end

    context "when attributes does not contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to false" do
        affiliate.should_not_receive(:is_validate_staged_header_footer=)
        affiliate.update_attributes_for_live(:staged_uses_managed_header_footer => '1',
                                             :staged_managed_header_home_url => 'http://usasearch.howto.gov')
      end
    end

    context "when attributes contain staged_uses_one_serp='1'" do
      it "should set is_validate_staged_header_footer to true" do
        affiliate.should_receive(:is_validate_staged_header_footer=).with(true)
        affiliate.update_attributes_for_live(:staged_uses_one_serp => '1',
                                             :staged_favicon_url => 'cdn.agency.gov/staged_favicon.ico')
      end
    end

    context "when attributes contain staged_uses_one_serp='0'" do
      it "should set is_validate_staged_header_footer to false" do
        affiliate.should_not_receive(:is_validate_staged_header_footer=)
        affiliate.update_attributes_for_live(:staged_uses_one_serp => '0',
                                             :staged_favicon_url => 'cdn.agency.gov/staged_favicon.ico')
      end
    end
  end

  describe "#set_attributes_from_staged_to_live" do
    let(:affiliate) { affiliate = Affiliate.create!(@valid_create_attributes) }
    let(:staged_header_image_file_name) { mock('staged header image file name') }

    it "should set live fields with values from staged fields" do
      Affiliate::ATTRIBUTES_WITH_STAGED_AND_LIVE.each do |attribute|
        staged_value = mock("staged_value for #{attribute}")
        affiliate.should_receive("staged_#{attribute}".to_sym).and_return(staged_value)
        affiliate.should_receive("#{attribute}=".to_sym).with(staged_value)
      end
      affiliate.set_attributes_from_staged_to_live
    end

    context "when staged_page_background_image and page_background_image are different" do
      let(:page_background_image) { mock('bg image') }

      before do
        affiliate.staged_page_background_image_file_name = 'staged_bg.gif'
        affiliate.staged_page_background_image_content_type = 'image/gif'
        affiliate.staged_page_background_image_file_size = 700
        affiliate.staged_page_background_image_updated_at = Date.current
        affiliate.page_background_image_file_name = 'live_bg.gif'
        affiliate.page_background_image_content_type = 'image/gif'
        affiliate.page_background_image_file_size = 800
        affiliate.page_background_image_updated_at = Date.current.yesterday
        affiliate.save!
      end

      it "should destroy page_background_image and set values from staged_page_background_image columns to page_background_image columns" do
        affiliate.should_receive(:page_background_image).and_return(page_background_image)
        page_background_image.should_receive(:destroy)
        affiliate.should_receive(:page_background_image_file_name=).with(affiliate.staged_page_background_image_file_name).ordered
        affiliate.should_receive(:page_background_image_content_type=).with(affiliate.staged_page_background_image_content_type)
        affiliate.should_receive(:page_background_image_file_size=).with(affiliate.staged_page_background_image_file_size)
        affiliate.should_receive(:page_background_image_updated_at=).with(affiliate.staged_page_background_image_updated_at)
        affiliate.set_attributes_from_staged_to_live
      end
    end

    context "when staged_page_background_image and page_background_image are the same" do
      before do
        page_background_image_updated_at = Date.current
        affiliate.staged_page_background_image_file_name = 'live_bg.gif'
        affiliate.staged_page_background_image_content_type = 'image/gif'
        affiliate.staged_page_background_image_file_size = 800
        affiliate.staged_page_background_image_updated_at = page_background_image_updated_at
        affiliate.page_background_image_file_name = 'live_bg.gif'
        affiliate.page_background_image_content_type = 'image/gif'
        affiliate.page_background_image_file_size = 800
        affiliate.page_background_image_updated_at = page_background_image_updated_at
        affiliate.save!
      end

      it "should set values from staged_page_background_image columns to page_background_image columns" do
        affiliate.should_not_receive(:page_background_image_file_name=)
        affiliate.should_not_receive(:page_background_image_content_type=)
        affiliate.should_not_receive(:page_background_image_file_size=)
        affiliate.should_not_receive(:page_background_image_updated_at=)
        affiliate.set_attributes_from_staged_to_live
      end
    end

    context "when staged_page_background_image exists and page_background_image does not exist" do
      before do
        affiliate.staged_page_background_image_file_name = 'staged_bg.gif'
        affiliate.staged_page_background_image_content_type = 'image/gif'
        affiliate.staged_page_background_image_file_size = 700
        affiliate.staged_page_background_image_updated_at = Date.current
        affiliate.page_background_image_file_name = nil
        affiliate.page_background_image_content_type = nil
        affiliate.page_background_image_file_size = nil
        affiliate.page_background_image_updated_at = nil
        affiliate.save!
      end

      it "should set values from staged_page_background_image columns to page_background_image columns" do
        affiliate.should_not_receive(:page_background_image)
        affiliate.set_attributes_from_staged_to_live
        affiliate.page_background_image_file_name.should == 'staged_bg.gif'
        affiliate.page_background_image_content_type.should == 'image/gif'
        affiliate.page_background_image_file_size.should == 700
        affiliate.page_background_image_updated_at.should == affiliate.staged_page_background_image_updated_at
      end
    end

    context "when staged_page_background_image does not exist and page_background_image exists" do
      let(:page_background_image) { mock('bg image') }

      before do
        affiliate.staged_page_background_image_file_name = nil
        affiliate.staged_page_background_image_content_type = nil
        affiliate.staged_page_background_image_file_size = nil
        affiliate.staged_page_background_image_updated_at = nil
        affiliate.page_background_image_file_name = 'live_bg.gif'
        affiliate.page_background_image_content_type = 'image/gif'
        affiliate.page_background_image_file_size = 800
        affiliate.page_background_image_updated_at = Date.current
        affiliate.save!
      end

      it "should set values from staged_page_background_image columns to page_background_image columns" do
        affiliate.should_receive(:page_background_image).and_return(page_background_image)
        page_background_image.should_receive(:destroy)
        affiliate.set_attributes_from_staged_to_live
        affiliate.page_background_image_file_name.should be_nil
        affiliate.page_background_image_content_type.should be_nil
        affiliate.page_background_image_file_size.should be_nil
        affiliate.page_background_image_updated_at.should be_nil
      end
    end

    context "when staged_header_image and header_image are different" do
      let(:header_image) { mock('header image') }

      before do
        affiliate.staged_header_image_file_name = 'staged.gif'
        affiliate.staged_header_image_content_type = 'image/gif'
        affiliate.staged_header_image_file_size = 700
        affiliate.staged_header_image_updated_at = Date.current
        affiliate.header_image_file_name = 'live.gif'
        affiliate.header_image_content_type = 'image/gif'
        affiliate.header_image_file_size = 800
        affiliate.header_image_updated_at = Date.current.yesterday
        affiliate.save!
      end

      it "should destroy header_image and set values from staged_header_image columns to header_image columns" do
        affiliate.should_receive(:header_image).and_return(header_image)
        header_image.should_receive(:destroy)
        affiliate.should_receive(:header_image_file_name=).with(affiliate.staged_header_image_file_name).ordered
        affiliate.should_receive(:header_image_content_type=).with(affiliate.staged_header_image_content_type)
        affiliate.should_receive(:header_image_file_size=).with(affiliate.staged_header_image_file_size)
        affiliate.should_receive(:header_image_updated_at=).with(affiliate.staged_header_image_updated_at)
        affiliate.set_attributes_from_staged_to_live
      end
    end

    context "when staged_header_image and header_image are the same" do
      before do
        header_image_updated_at = Date.current
        affiliate.staged_header_image_file_name = 'live.gif'
        affiliate.staged_header_image_content_type = 'image/gif'
        affiliate.staged_header_image_file_size = 800
        affiliate.staged_header_image_updated_at = header_image_updated_at
        affiliate.header_image_file_name = 'live.gif'
        affiliate.header_image_content_type = 'image/gif'
        affiliate.header_image_file_size = 800
        affiliate.header_image_updated_at = header_image_updated_at
        affiliate.save!
      end

      it "should set values from staged_header_image columns to header_image columns" do
        affiliate.should_not_receive(:header_image_file_name=)
        affiliate.should_not_receive(:header_image_content_type=)
        affiliate.should_not_receive(:header_image_file_size=)
        affiliate.should_not_receive(:header_image_updated_at=)
        affiliate.set_attributes_from_staged_to_live
      end
    end

    context "when staged_header_image exists and header_image does not exist" do
      before do
        affiliate.staged_header_image_file_name = 'staged.gif'
        affiliate.staged_header_image_content_type = 'image/gif'
        affiliate.staged_header_image_file_size = 700
        affiliate.staged_header_image_updated_at = Date.current
        affiliate.header_image_file_name = nil
        affiliate.header_image_content_type = nil
        affiliate.header_image_file_size = nil
        affiliate.header_image_updated_at = nil
        affiliate.save!
      end

      it "should set values from staged_header_image columns to header_image columns" do
        affiliate.should_not_receive(:header_image)
        affiliate.set_attributes_from_staged_to_live
        affiliate.header_image_file_name.should == 'staged.gif'
        affiliate.header_image_content_type.should == 'image/gif'
        affiliate.header_image_file_size.should == 700
        affiliate.header_image_updated_at.should == affiliate.staged_header_image_updated_at
      end
    end

    context "when staged_header_image does not exist and header_image exists" do
      let(:header_image) { mock('header image') }

      before do
        affiliate.staged_header_image_file_name = nil
        affiliate.staged_header_image_content_type = nil
        affiliate.staged_header_image_file_size = nil
        affiliate.staged_header_image_updated_at = nil
        affiliate.header_image_file_name = 'live.gif'
        affiliate.header_image_content_type = 'image/gif'
        affiliate.header_image_file_size = 800
        affiliate.header_image_updated_at = Date.current
        affiliate.save!
      end

      it "should set values from staged_header_image columns to header_image columns" do
        affiliate.should_receive(:header_image).and_return(header_image)
        header_image.should_receive(:destroy)
        affiliate.set_attributes_from_staged_to_live
        affiliate.header_image_file_name.should be_nil
        affiliate.header_image_content_type.should be_nil
        affiliate.header_image_file_size.should be_nil
        affiliate.header_image_updated_at.should be_nil
      end
    end
  end

  describe "#set_attributes_from_live_to_staged" do
    let(:affiliate) { affiliate = Affiliate.create!(@valid_create_attributes) }
    let(:header_image_file_name) { mock('header image file name') }

    it "should set staged fields with values from live fields" do
      Affiliate::ATTRIBUTES_WITH_STAGED_AND_LIVE.each do |attribute|
        live_value = mock("live_value for #{attribute}")
        affiliate.should_receive("#{attribute}".to_sym).and_return(live_value)
        affiliate.should_receive("staged_#{attribute}=".to_sym).with(live_value)
      end
      affiliate.set_attributes_from_live_to_staged
    end

    context "when existing staged_page_background_image and page_background_image are different" do
      let(:staged_page_background_image) { mock('staged page background image') }

      before do
        affiliate.staged_page_background_image_file_name = 'staged_bg.jpg'
        affiliate.staged_page_background_image_content_type = 'image/jpeg'
        affiliate.staged_page_background_image_file_size = 700
        affiliate.staged_page_background_image_updated_at = Date.current
        affiliate.page_background_image_file_name = 'live_bg.gif'
        affiliate.page_background_image_content_type = 'image/gif'
        affiliate.page_background_image_file_size = 800
        affiliate.page_background_image_updated_at = Date.current.yesterday
        affiliate.save!
      end

      it "should destroy existing staged_page_background_image" do
        affiliate.should_receive(:staged_page_background_image).and_return(staged_page_background_image)
        staged_page_background_image.should_receive(:destroy)
        affiliate.set_attributes_from_live_to_staged
        affiliate.staged_page_background_image_file_name.should == 'live_bg.gif'
        affiliate.staged_page_background_image_content_type.should == 'image/gif'
        affiliate.staged_page_background_image_file_size.should == 800
        affiliate.staged_page_background_image_updated_at.should == affiliate.page_background_image_updated_at
      end
    end

    context "when staged_page_background_image does not exist and page_background_image exists" do
      before do
        affiliate.staged_page_background_image_file_name = nil
        affiliate.staged_page_background_image_content_type = nil
        affiliate.staged_page_background_image_file_size = nil
        affiliate.staged_page_background_image_updated_at = nil
        affiliate.page_background_image_file_name = 'live_bg.gif'
        affiliate.page_background_image_content_type = 'image/gif'
        affiliate.page_background_image_file_size = 800
        affiliate.page_background_image_updated_at = Date.current
        affiliate.save!
      end

      it "should set values from page_background_image columns to staged_page_background_image columns" do
        affiliate.should_not_receive(:staged_page_background_image)
        affiliate.set_attributes_from_live_to_staged
        affiliate.staged_page_background_image_file_name.should == 'live_bg.gif'
        affiliate.staged_page_background_image_content_type.should == 'image/gif'
        affiliate.staged_page_background_image_file_size.should == 800
        affiliate.staged_page_background_image_updated_at.should == affiliate.page_background_image_updated_at
      end
    end

    context "when staged_page_background_image exists and page_background_image does not exist" do
      let(:staged_page_background_image) { mock('staged page background image') }

      before do
        affiliate.staged_page_background_image_file_name = 'staged_bg.jpg'
        affiliate.staged_page_background_image_content_type = 'image/jpeg'
        affiliate.staged_page_background_image_file_size = 700
        affiliate.staged_page_background_image_updated_at = Date.current
        affiliate.page_background_image_file_name = nil
        affiliate.page_background_image_content_type = nil
        affiliate.page_background_image_file_size = nil
        affiliate.page_background_image_updated_at = nil
        affiliate.save!
      end

      it "should destroy existing staged_page_background_image" do
        affiliate.should_receive(:staged_page_background_image).and_return(staged_page_background_image)
        staged_page_background_image.should_receive(:destroy)
        affiliate.set_attributes_from_live_to_staged
        affiliate.staged_page_background_image_file_name.should be_nil
        affiliate.staged_page_background_image_content_type.should be_nil
        affiliate.staged_page_background_image_file_size.should be_nil
        affiliate.staged_page_background_image_updated_at.should be_nil
      end
    end

    context "when existing staged_header_image and header_image are different" do
      let(:staged_header_image) { mock('staged header image') }

      before do
        affiliate.staged_header_image_file_name = 'staged.jpg'
        affiliate.staged_header_image_content_type = 'image/jpeg'
        affiliate.staged_header_image_file_size = 700
        affiliate.staged_header_image_updated_at = Date.current
        affiliate.header_image_file_name = 'live.gif'
        affiliate.header_image_content_type = 'image/gif'
        affiliate.header_image_file_size = 800
        affiliate.header_image_updated_at = Date.current.yesterday
        affiliate.save!
      end

      it "should destroy existing staged_header_image" do
        affiliate.should_receive(:staged_header_image).and_return(staged_header_image)
        staged_header_image.should_receive(:destroy)
        affiliate.set_attributes_from_live_to_staged
        affiliate.staged_header_image_file_name.should == 'live.gif'
        affiliate.staged_header_image_content_type.should == 'image/gif'
        affiliate.staged_header_image_file_size.should == 800
        affiliate.staged_header_image_updated_at.should == affiliate.header_image_updated_at
      end
    end

    context "when staged_header_image does not exist and header_image exists" do
      before do
        affiliate.staged_header_image_file_name = nil
        affiliate.staged_header_image_content_type = nil
        affiliate.staged_header_image_file_size = nil
        affiliate.staged_header_image_updated_at = nil
        affiliate.header_image_file_name = 'live.gif'
        affiliate.header_image_content_type = 'image/gif'
        affiliate.header_image_file_size = 800
        affiliate.header_image_updated_at = Date.current
        affiliate.save!
      end

      it "should set values from header_image columns to staged_header_image columns" do
        affiliate.should_not_receive(:staged_header_image)
        affiliate.set_attributes_from_live_to_staged
        affiliate.staged_header_image_file_name.should == 'live.gif'
        affiliate.staged_header_image_content_type.should == 'image/gif'
        affiliate.staged_header_image_file_size.should == 800
        affiliate.staged_header_image_updated_at.should == affiliate.header_image_updated_at
      end
    end

    context "when staged_header_image exists and header_image does not exist" do
      let(:staged_header_image) { mock('staged header image') }

      before do
        affiliate.staged_header_image_file_name = 'staged.jpg'
        affiliate.staged_header_image_content_type = 'image/jpeg'
        affiliate.staged_header_image_file_size = 700
        affiliate.staged_header_image_updated_at = Date.current
        affiliate.header_image_file_name = nil
        affiliate.header_image_content_type = nil
        affiliate.header_image_file_size = nil
        affiliate.header_image_updated_at = nil
        affiliate.save!
      end

      it "should destroy existing staged_header_image" do
        affiliate.should_receive(:staged_header_image).and_return(staged_header_image)
        staged_header_image.should_receive(:destroy)
        affiliate.set_attributes_from_live_to_staged
        affiliate.staged_header_image_file_name.should be_nil
        affiliate.staged_header_image_content_type.should be_nil
        affiliate.staged_header_image_file_size.should be_nil
        affiliate.staged_header_image_updated_at.should be_nil
      end
    end
  end

  describe "#template" do
    it "should return the affiliate template if present" do
      affiliate = Affiliate.new(@valid_create_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.uses_one_serp = false
      affiliate.save!
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
      affiliate.template.should == affiliate.affiliate_template
    end

    it "should return the default affiliate template if no affiliate template" do
      affiliate = Affiliate.new(@valid_create_attributes.merge(:affiliate_template_id => -1))
      affiliate.uses_one_serp = false
      affiliate.save!
      affiliate.affiliate_template.should be_nil
      affiliate.template.should == AffiliateTemplate.default_template
    end
  end

  describe "#human_attribute_name" do
    Affiliate.human_attribute_name("display_name").should == "Site name"
    Affiliate.human_attribute_name("name").should == "Site Handle (visible to searchers in the URL)"
    Affiliate.human_attribute_name("staged_search_results_page_title").should == "Search results page title"
  end

  describe "#build_search_results_page_title" do
    let(:affiliate) { Affiliate.create(@valid_create_attributes.merge(:locale => 'en')) }

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
    let(:affiliate) { Affiliate.create(@valid_create_attributes.merge(:locale => 'en')) }

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

  describe "#push_staged_changes" do
    it "should set attributes from staged to live fields, set has_staged_content to false and save!" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.should_receive(:set_attributes_from_staged_to_live)
      affiliate.should_receive(:has_staged_content=).with(false)
      affiliate.should_receive(:save!)
      affiliate.push_staged_changes
    end
  end

  describe "#cancel_staged_changes" do
    it "should set attributes from live to staged fields, set has_staged_content to false and save!" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.should_receive(:set_attributes_from_live_to_staged)
      affiliate.should_receive(:has_staged_content=).with(false)
      affiliate.should_receive(:save!)
      affiliate.cancel_staged_changes
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
      let(:css_property_hash) { {:title_link_color => '#33ff33', :visited_title_link_color => '#0000ff'}.reverse_merge(Affiliate::DEFAULT_CSS_PROPERTIES) }
      let(:affiliate) { Affiliate.create!(@valid_create_attributes.merge(:theme => 'custom', :css_property_hash => css_property_hash)) }

      specify { affiliate.css_property_hash(true).should == css_property_hash }
    end

    context "when theme is not custom" do
      let(:css_property_hash) { {:font_family => Affiliate::FONT_FAMILIES.last} }
      let(:affiliate) { Affiliate.create!(
        @valid_create_attributes.merge(:theme => 'elegant',
                                       :css_property_hash => css_property_hash)) }

      specify { affiliate.css_property_hash(true).should == Affiliate::THEMES[:elegant].reverse_merge(css_property_hash) }
    end
  end

  describe "#staged_css_property_hash" do
    context "when theme is custom" do
      let(:staged_css_property_hash) { {:title_link_color => '#33ff33', :visited_title_link_color => '#0000ff'}.reverse_merge(Affiliate::DEFAULT_CSS_PROPERTIES) }
      let(:affiliate) { Affiliate.create!(@valid_create_attributes.merge(:theme => 'natural', :staged_theme => 'custom', :staged_css_property_hash => staged_css_property_hash)) }

      specify { affiliate.staged_css_property_hash(true).should == staged_css_property_hash }
    end

    context "when theme is not custom" do
      let(:staged_css_property_hash) { {:font_family => Affiliate::FONT_FAMILIES.last} }
      let(:affiliate) { Affiliate.create!(
        @valid_create_attributes.merge(:theme => 'natural',
                                       :staged_theme => 'elegant',
                                       :staged_css_property_hash => staged_css_property_hash)) }

      specify { affiliate.staged_css_property_hash(true).should == Affiliate::THEMES[:elegant].reverse_merge(staged_css_property_hash) }
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
        site_domains[1].domain.should == 'bar.gov/somedir'
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
    let(:affiliate) { affiliate = Affiliate.create!(@valid_create_attributes) }
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

  describe "#uses_bing_results?" do
    before do
      @affiliate = affiliates(:basic_affiliate)
    end

    context "when affiliate has results_source=='bing'" do
      before do
        @affiliate.results_source = 'bing'
      end

      it "should return true" do
        @affiliate.uses_bing_results?.should be_true
      end
    end

    context "when affiliate has results_source not equal to 'bing'" do
      before do
        @affiliate.results_source = 'odie'
      end

      it "should return false" do
        @affiliate.uses_bing_results?.should be_false
      end
    end
  end

  describe "#refresh_indexed_documents(scope)" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @affiliate.fetch_concurrency = 2
      @first = @affiliate.indexed_documents.build(:url => 'http://some.mil/')
      @second = @affiliate.indexed_documents.build(:url => 'http://some.mil/foo')
      @third = @affiliate.indexed_documents.build(:url => 'http://some.mil/bar')
      @ok = @affiliate.indexed_documents.build(:title => 'PDF Title',
                                               :description => 'This is a PDF document.',
                                               :url => 'http://something.gov/pdf.pdf',
                                               :last_crawl_status => IndexedDocument::OK_STATUS,
                                               :last_crawled_at => Time.now,
                                               :body => "this is the doc body",
                                               :content_hash => "a6e450cc50ac3b3b7788b50b3b73e8b0b7c197c8")
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

      affiliate = Affiliate.create!(@valid_attributes.merge(:header => tainted_header))
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

      affiliate = Affiliate.create!(@valid_attributes.merge(:footer => tainted_footer))
      affiliate.sanitized_footer.strip.should == %q(<h1 id="my_footer">footer</h1>)
    end
  end

  describe "#unused_features" do
    fixtures :features
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

  context "when updating the twitter_handle field" do
    before do
      @twitter_user = mock(Object)
      @twitter_user.stub!(:id).and_return 123
      @twitter_user.stub!(:screen_name).and_return "NewHandle"
      @twitter_user.stub!(:profile_image_url).and_return 'http://a0.twimg.com/profile_images/2183009986/normal.jpg'
      @affiliate = affiliates(:basic_affiliate)
    end

    it "should associate the affiliate with either an existing or new TwitterProfile if the twitter_handle field is updated" do
      TwitterProfile.find_by_screen_name("NewHandle").should be_nil
      Twitter.should_receive(:user).with("NewHandle").and_return(@twitter_user)
      @affiliate.update_attributes(:twitter_handle => 'NewHandle')
      TwitterProfile.find_by_screen_name("NewHandle").should_not be_nil
    end

    context "when Twitter raises an error" do
      before do
        Twitter.should_receive(:user).and_raise "Some Error"
      end

      it "should complete the save without an error" do
        @affiliate.update_attributes(:twitter_handle => 'NewHandle')
        TwitterProfile.find_by_screen_name("NewHandle").should be_nil
        @affiliate.twitter_handle.should == 'NewHandle'
      end
    end
  end

  describe "#autodiscover" do
    before do
      @affiliate = affiliates(:basic_affiliate)
    end

    context "when a single site domain exists" do
      before do
        @affiliate.site_domains << SiteDomain.new(:site_name => 'nps.gov', :domain => 'nps.gov')
      end

      it "should call autodiscover for sitemaps, rss feeds and favicons" do
        @affiliate.should_receive(:autodiscover_sitemap).and_return true
        @affiliate.should_receive(:autodiscover_rss_feeds).and_return true
        @affiliate.should_receive(:autodiscover_favicon_url).and_return true
        @affiliate.should_receive(:autodiscover_social_media).and_return true
        @affiliate.autodiscover
      end
    end

    context "when more than a single site_domain exists" do
      before do
        @affiliate.site_domains << SiteDomain.new(:site_name => 'first.nps.gov', :domain => 'first.nps.gov')
        @affiliate.site_domains << SiteDomain.new(:site_name => 'second.nps.gov', :domain => 'second.nps.gov')
      end

      it "should not autodiscover anything" do
        @affiliate.should_not_receive(:autodiscover_sitemap)
        @affiliate.should_not_receive(:autodiscover_rss_feeds)
        @affiliate.should_not_receive(:autodiscover_favicon_url)
        @affiliate.should_not_receive(:autodiscover_social_media)
        @affiliate.autodiscover
      end
    end
  end

  describe "#autodiscover_sitemap" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @affiliate.site_domains << SiteDomain.new(:site_name => 'NPS.gov', :domain => 'nps.gov')
    end

    context "when the affiliate's robots.txt has a reference to a sitemap" do
      before do
        robot = Robot.new
        robot.stub!(:sitemap).and_return "http://nps.gov/sitemap.xml"
        Robot.stub!(:find_or_create_by_domain).and_return(robot)
      end

      it "should add the sitemap to the list of sitemaps for the affiliate" do
        Sitemap.should_receive(:create).with(:url => "http://nps.gov/sitemap.xml", :affiliate => @affiliate)
        @affiliate.autodiscover_sitemap
      end
    end

    context "when the affiliate's robots.txt does not reference a sitemap" do
      before do
        robot = Robot.new
        robot.stub!(:sitemap).and_return nil
        Robot.stub!(:find_or_create_by_domain).and_return(robot)
      end

      it "should not add a sitemap" do
        Sitemap.should_not_receive(:create)
        @affiliate.autodiscover_sitemap
      end
    end

    context "when something goes horribly wrong" do
      before do
        Robot.stub!(:find_or_create_by_domain).and_raise "Some Exception"
      end

      it "should log an error" do
        Rails.logger.should_receive(:error).with("Error when autodiscovering sitemap for #{@affiliate.name}: Some Exception")
        @affiliate.autodiscover_sitemap
      end
    end
  end

  describe "#autodiscover_rss_feeds" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @affiliate.site_domains << SiteDomain.new(:site_name => 'USA.gov', :domain => 'usa.gov')
      @affiliate.rss_feeds.destroy_all
    end

    context "when the home page has alternate links to an rss feed" do
      before do
        stub!(:open).and_return File.read(Rails.root.to_s + "/spec/fixtures/html/usa_gov/site_index.html")
        Kernel.stub!(:open).and_return File.read(Rails.root.to_s + "/spec/fixtures/rss/wh_blog.xml")
      end

      it "should add the feed to the affiliate's rss feeds" do
        @affiliate.rss_feeds.size.should == 0
        @affiliate.autodiscover_rss_feeds
        @affiliate.reload
        @affiliate.rss_feeds.size.should == 2
      end

      it "should not re-fetch the home page content if it's already been fetched" do
        @affiliate.autodiscover_rss_feeds
        Nokogiri::HTML::Document.should_not_receive(:parse)
        @affiliate.autodiscover_rss_feeds
      end
    end

    context "when the home page does not have links to an rss feed" do
      before do
      end

      it "should not create any rss feeds" do
        @affiliate.rss_feeds.size.should == 0
        @affiliate.autodiscover_rss_feeds
        @affiliate.rss_feeds.size.should == 0
      end
    end

    context "when something goes horribly wrong" do
      before { @affiliate.should_receive(:open).and_raise 'Some Exception' }

      it "should log an error" do
        Rails.logger.should_receive(:error).with("Error when autodiscovering rss feeds for #{@affiliate.name}: Some Exception")
        @affiliate.autodiscover_rss_feeds
      end
    end
  end

  describe "#autodiscover_favicon_url" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @affiliate.site_domains << SiteDomain.new(:site_name => 'NPS.gov', :domain => 'nps.gov')
      @affiliate.update_attributes(:favicon_url => nil)
    end

    context "when the favicon link is an absolute path" do
      before do
        page_with_favicon = File.open(Rails.root.to_s + '/spec/fixtures/html/home_page_with_icon_link.html')
        @affiliate.should_receive(:open).and_return(page_with_favicon)
      end

      it "should update the affiliate's favicon_url attribute with the value" do
        @affiliate.autodiscover_favicon_url
        @affiliate.favicon_url.should_not be_nil
        @affiliate.favicon_url.should == "http://usa.gov/resources/images/usa_favicon.gif"
      end

      it "should not check the home page content more than once if a local copy is available" do
        @affiliate.autodiscover_favicon_url
        Nokogiri::HTML.should_not_receive(:new)
        @affiliate.should_not_receive(:open)
        @affiliate.autodiscover_favicon_url
      end
    end

    context "when the favicon link is a relative path" do
      before do
        page_with_favicon = File.open(Rails.root.to_s + '/spec/fixtures/html/home_page_with_relative_icon_link.html')
        @affiliate.should_receive(:open).and_return(page_with_favicon)
      end

      it "should store a full url as the favicon link" do
        @affiliate.autodiscover_favicon_url
        @affiliate.favicon_url.should_not be_nil
        @affiliate.favicon_url.should == "http://nps.gov/resources/images/usa_favicon.gif"
      end
    end

    context "when no favicon link is present in the HTML, but a file at http://domain.gov/favicon.ico exists" do
      it "should update the affiliate's favicon_url attribute" do
        @affiliate.should_receive(:open).with("http://nps.gov").and_return File.read(Rails.root.to_s + "/spec/fixtures/html/page_with_no_links.html")
        @affiliate.should_receive(:open).with("http://nps.gov/favicon.ico").and_return File.read(Rails.root.to_s + "/spec/fixtures/ico/favicon.ico")
        @affiliate.autodiscover_favicon_url
        @affiliate.favicon_url.should_not be_nil
        @affiliate.favicon_url.should == "http://nps.gov/favicon.ico"
      end
    end

    context "when no favicon link is present in HTML and no file exists at the default location" do
      before do
        @affiliate.should_receive(:open).with("http://nps.gov").and_return File.read(Rails.root.to_s + "/spec/fixtures/html/page_with_no_links.html")
        @affiliate.should_receive(:open).with("http://nps.gov/favicon.ico").and_raise "Some Exception"
      end

      it "should not update the affiliate's favicon_url attribute" do
        @affiliate.autodiscover_favicon_url
        @affiliate.favicon_url.should be_nil
      end
    end

    context "when something goes horribly wrong" do
      before { @affiliate.should_receive(:open).and_raise 'Some Exception' }

      it "should log an error" do
        Rails.logger.should_receive(:error).with("Error when autodiscovering favicon for #{@affiliate.name}: Some Exception")
        @affiliate.autodiscover_favicon_url
      end
    end
  end

  describe "#autodiscover_social_media" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @affiliate.site_domains << SiteDomain.new(:site_name => 'NPS.gov', :domain => 'nps.gov')
    end

    context "when the page has social media links" do
      before do
        page_with_social_media_urls = File.open(Rails.root.to_s + '/spec/fixtures/html/home_page_with_social_media_urls.html')
        @affiliate.should_receive(:open).and_return(page_with_social_media_urls)
        @affiliate.autodiscover_social_media
      end

      it "should update the twitter handle with the first twitter handle found" do
        @affiliate.twitter_handle.should == "whitehouse"
      end

      it "should update the facebook handle with the first Facebook handle found" do
        @affiliate.facebook_handle.should == "whitehouse"
      end

      it "should update the flickr url with the first Flickr url found" do
        @affiliate.flickr_url.should == "http://flickr.com/whitehouse"
      end

      it "should update the youtube handles with all the youtube handles found on the page" do
        @affiliate.youtube_handles.should == ["whitehouse", "whitehouse2"]
      end

      context "when there are existing youtube handles" do
        before do
          @affiliate.update_attributes(:youtube_handles => ['whitehouse_test'])
        end

        it "should add new handles to the list" do
          @affiliate.autodiscover_social_media
          @affiliate.youtube_handles.should == ["whitehouse", "whitehouse2", "whitehouse_test"]
        end
      end
    end

    context "when the page has no valid social media links" do
      before do
        page_with_bad_social_media_urls = File.open(Rails.root.to_s + '/spec/fixtures/html/home_page_with_bad_social_media_urls.html')
        @affiliate.should_receive(:open).and_return(page_with_bad_social_media_urls)
        @affiliate.autodiscover_social_media
      end

      it "should not update the twitter handle" do
        @affiliate.twitter_handle.should be_nil
      end

      it "should not update the facebook handle" do
        @affiliate.facebook_handle.should be_nil
      end

      it "should not update the flickr handle" do
        @affiliate.flickr_url.should be_nil
      end

      it "should not update the youtube handles" do
        @affiliate.youtube_handles.should be_nil
      end
    end

    context "when something goes horribly wrong" do
      before { @affiliate.should_receive(:open).and_raise 'Some Exception' }

      it "should log an error" do
        Rails.logger.should_receive(:error).with("Error when autodiscovering social media for #{@affiliate.name}: Some Exception")
        @affiliate.autodiscover_social_media
      end
    end

  end

  describe "#import_flickr_photos" do
    before do
      @affiliate = affiliates(:basic_affiliate)
    end

    it "should import the photos from Flickr" do
      FlickrPhoto.should_receive(:import_photos).with(@affiliate).and_return true
      @affiliate.import_flickr_photos
    end
  end
end