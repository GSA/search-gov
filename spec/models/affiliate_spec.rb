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
    ["data.gov", "ct-new", "some_aff", "123", "NewAff"].each do |value|
      it { should allow_value(value).for(:name) }
    end
    it { should have_and_belong_to_many :users }
    it { should have_many :boosted_contents }
    it { should have_many :sayt_suggestions }
    it { should have_many(:popular_urls).dependent(:destroy) }
    it { should have_many(:featured_collections).dependent(:destroy) }
    it { should have_many(:rss_feeds).dependent(:destroy) }
    it { should have_many(:site_domains).dependent(:destroy)}
    it { should have_many(:indexed_domains).dependent(:destroy)}
    it { should belong_to :affiliate_template }
    it { should belong_to :staged_affiliate_template }
    it { should_not allow_mass_assignment_of(:uses_one_serp) }
    it { should_not allow_mass_assignment_of(:previous_fields_json) }
    it { should_not allow_mass_assignment_of(:live_fields_json) }
    it { should_not allow_mass_assignment_of(:staged_fields_json) }
    it { should have_attached_file :header_image }
    it { should have_attached_file :staged_header_image }
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
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:name => 'AffiliateSite'))
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
        JSON.parse(affiliate.css_properties, :symbolize_keys => true)[:title_link_color].should == '#33ff33'
        JSON.parse(affiliate.css_properties, :symbolize_keys => true)[:visited_title_link_color].should == '#0000ff'
      end

      it "should update staged_css_properties with json string from staged_css property hash" do
        staged_css_property_hash = { 'title_link_color' => '#33ff33', 'visited_title_link_color' => '#0000ff' }
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

      it "should have SAYT enabled by default" do
        Affiliate.create!(@valid_create_attributes).is_sayt_enabled.should be_true
      end

      it "should generate a database-level error when attempting to add an affiliate with the same name as an existing affiliate, but with different case; instead it should return false" do
        Affiliate.create!(@valid_attributes)
        @duplicate_affiliate = Affiliate.new(@valid_attributes.merge(:name => @valid_attributes[:name].upcase))
        @duplicate_affiliate.save.should be_false
      end

      it "should populate search labels for English site" do
        affiliate = Affiliate.create!(@valid_attributes.merge(:locale => 'en'))
        affiliate.default_search_label.should == 'Everything'
        affiliate.image_search_label.should == 'Images'
      end

      it "should populate search labels for Spanish site" do
        affiliate = Affiliate.create!(@valid_attributes.merge(:locale => 'es'))
        affiliate.default_search_label.should == 'Todo'
        affiliate.image_search_label.should == 'Imágenes'
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
      affiliate.css_property_hash = { :page_background_color => '#FFFFFF' }
      affiliate.staged_theme = 'fun_blue'
      affiliate.staged_css_property_hash = { :page_background_color => '#FFFFFF' }
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
      affiliate.css_property_hash = { :font_family => 'Verdana, sans-serif' }
      affiliate.staged_css_property_hash = { :font_family => 'Georgia, serif' }
      affiliate.save!
      Affiliate.find(affiliate.id).css_property_hash[:font_family].should == 'Verdana, sans-serif'
      Affiliate.find(affiliate.id).staged_css_property_hash[:font_family].should == 'Georgia, serif'
    end

    it "should set header_footer_sass fields" do
      affiliate.update_attributes!(:staged_header_footer_css => 'h1 { color: blue} ', :header_footer_css => '')
      affiliate.staged_header_footer_sass.should =~ /color\: blue/
      affiliate.header_footer_sass.should be_blank
      affiliate.update_attributes!(:staged_header_footer_css => '', :header_footer_css => 'live.h1 { color: red }')
      affiliate.staged_header_footer_sass.should be_blank
      affiliate.header_footer_sass.should =~ /color\: red/
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
      staged_managed_header_links_attributes = { "0" => { :position => '1', :title => 'Blog', :url => 'http://blog.agency.gov' },
                                                 "1" => { :position => '0', :title => 'News', :url => 'http://news.agency.gov' },
                                                 "2" => { :position => '2', :title => 'Services', :url => 'http://services.agency.gov' } }
      affiliate.update_attributes!(:staged_managed_header_links_attributes => staged_managed_header_links_attributes)
      affiliate.staged_managed_header_links.should == [{ :position => 0, :title => 'News', :url => 'http://news.agency.gov' },
                                                       { :position => 1, :title => 'Blog', :url => 'http://blog.agency.gov'},
                                                       { :position => 2, :title => 'Services', :url => 'http://services.agency.gov'}]
    end

    it "should set staged_managed_footer_links" do
      staged_managed_footer_links_attributes = { "0" => { :position => '1', :title => 'About Us', :url => 'http://about.agency.gov' },
                                                 "1" => { :position => '0', :title => 'Home', :url => 'http://www.agency.gov' },
                                                 "2" => { :position => '2', :title => 'Contact Us', :url => 'http://contact.agency.gov' } }
      affiliate.update_attributes!(:staged_managed_footer_links_attributes => staged_managed_footer_links_attributes)
      affiliate.staged_managed_footer_links.should == [{ :position => 0, :title => 'Home', :url => 'http://www.agency.gov' },
                                                       { :position => 1, :title => 'About Us', :url => 'http://about.agency.gov'},
                                                       { :position => 2, :title => 'Contact Us', :url => 'http://contact.agency.gov'}]
    end

    context "when there is an existing image" do
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

      context "when uploading a new image" do
        it "should not clear the existing image" do
          staged_header_image.should_receive(:dirty?).and_return(true)
          staged_header_image.should_not_receive(:clear)
          affiliate.update_attributes!(@update_params)
        end
      end
    end

    it "should populate search labels for English site" do
      english_affiliate = Affiliate.create!(@valid_attributes.merge(:locale => 'en'))
      english_affiliate.default_search_label = ''
      english_affiliate.image_search_label = ''
      english_affiliate.save!
      english_affiliate.default_search_label.should == 'Everything'
      english_affiliate.image_search_label.should == 'Images'
    end

    it "should populate search labels for Spanish site" do
      spanish_affiliate = Affiliate.create!(@valid_attributes.merge(:locale => 'es'))
      spanish_affiliate.default_search_label = ''
      spanish_affiliate.image_search_label = ''
      spanish_affiliate.save!
      spanish_affiliate.default_search_label.should == 'Todo'
      spanish_affiliate.image_search_label.should == 'Imágenes'
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

    it "should not change the name attribute on update" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      lambda { affiliate.update_attributes(:name => "") }.should raise_error("This field cannot be changed.")
      affiliate.name.should == "myawesomesite"
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
        css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({ 'left_tab_text_color' => "#{valid_color}",
                                                                           'title_link_color' => "#{valid_color}",
                                                                           'visited_title_link_color' => "#{valid_color}",
                                                                           'description_text_color' => "#{valid_color}",
                                                                           'url_link_color' => "#{valid_color}" })
        Affiliate.new(@valid_create_attributes.merge(:css_property_hash => css_property_hash)).should be_valid
      end
    end

    it "should be invalid when color property in css property hash does not consist of a # character followed by 3 or 6 hexadecimal digits " do
      %w{ 333 invalid #err #1 #22 #4444 #55555 ffffff 1 22 4444 55555 666666 }.each do |invalid_color|
        css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({ 'left_tab_text_color' => "#{invalid_color}",
                                                                           'title_link_color' => "#{invalid_color}",
                                                                           'visited_title_link_color' => "#{invalid_color}",
                                                                           'description_text_color' => "#{invalid_color}",
                                                                           'url_link_color' => "#{invalid_color}" })
        affiliate = Affiliate.new(@valid_create_attributes.merge(:css_property_hash => css_property_hash))
        affiliate.should_not be_valid
        affiliate.errors[:base].should include("Title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
        affiliate.errors[:base].should include("Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
        affiliate.errors[:base].should include("Description text color should consist of a # character followed by 3 or 6 hexadecimal digits")
        affiliate.errors[:base].should include("Url link color should consist of a # character followed by 3 or 6 hexadecimal digits")
      end
    end

    it "should validate color property in staged css property hash" do
      staged_css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({ 'title_link_color' => 'invalid', 'visited_title_link_color' => '#DDDD' })
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
      staged_managed_header_links_attributes = { "0" => { :position => '1', :title => '', :url => 'blog.agency.gov' },
                                                 "1" => { :position => '0', :title => 'News', :url => 'http://news.agency.gov' } }
      affiliate.update_attributes(:staged_managed_header_links_attributes => staged_managed_header_links_attributes).should be_false
      affiliate.errors.count.should == 1
      affiliate.errors[:base].first.should match(/Header link title can't be blank/)
    end

    it "should validate staged_managed_header_links URL" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      staged_managed_header_links_attributes = { "0" => { :position => '1', :title => 'Blog', :url => 'blog' },
                                                 "1" => { :position => '0', :title => 'News', :url => '' } }
      affiliate.update_attributes(:staged_managed_header_links_attributes => staged_managed_header_links_attributes).should be_false
      affiliate.errors.count.should == 1
      affiliate.errors[:base].last.should match(/Header link URL can't be blank/)
    end

    it "should validate staged_managed_footer_links title" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      staged_managed_footer_links_attributes = { "0" => { :position => '1', :title => '', :url => 'about.agency.gov' },
                                                 "1" => { :position => '0', :title => 'Home', :url => 'http://www.agency.gov' } }
      affiliate.update_attributes(:staged_managed_footer_links_attributes => staged_managed_footer_links_attributes).should be_false
      affiliate.errors.count.should == 1
      affiliate.errors[:base].first.should match(/Footer link title can't be blank/)
    end

    it "should validate staged_managed_footer_links URL" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      staged_managed_footer_links_attributes = { "0" => { :position => '1', :title => 'About Us', :url => 'http://about.agency.gov' },
                                                 "1" => { :position => '0', :title => 'Home', :url => '' } }
      affiliate.update_attributes(:staged_managed_footer_links_attributes => staged_managed_footer_links_attributes).should be_false
      affiliate.errors.count.should == 1
      affiliate.errors[:base].last.should match(/Footer link URL can't be blank/)
    end

    context "is_updating_staged_header_footer is set to true" do
      context "site uses staged one serp and staged custom header footer" do
        let(:affiliate) { Affiliate.create!(:display_name => 'test header footer validation',
                                            :uses_one_serp => true,
                                            :staged_uses_one_serp => true,
                                            :uses_managed_header_footer => false,
                                            :staged_uses_managed_header_footer => false) }
        it "should not allow script, style or link elements in staged header or staged footer" do
          header_error_message = %q(HTML to customize the top of your search results page can't contain script, style or link elements)
          footer_error_message = %q(HTML to customize the bottom of your search results page can't contain script, style or link elements)
          affiliate.is_updating_staged_header_footer = true

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
          affiliate.update_attributes(:staged_header => html_with_style , :staged_footer => html_with_style).should be_false
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
          header_error_message = %q(HTML to customize the top of your search results page can't be malformed)
          footer_error_message = %q(HTML to customize the bottom of your search results page can't be malformed)
          affiliate.is_updating_staged_header_footer = true

          malformed_html_fragments = <<-HTML
            <link href="http://cdn.agency.gov/link.css"></script>
            <h1>html with link</h1>
          HTML
          affiliate.update_attributes(:staged_header => malformed_html_fragments, :staged_footer => malformed_html_fragments).should be_false
          affiliate.errors[:base].join.should match(/#{header_error_message}/)
          affiliate.errors[:base].join.should match(/#{footer_error_message}/)
        end
      end

      context "site uses staged one serp and staged managed header footer" do
        let(:affiliate) { Affiliate.create!(:display_name => 'test header footer validation',
                                            :uses_one_serp => true,
                                            :staged_uses_one_serp => true,
                                            :uses_managed_header_footer => true,
                                            :staged_uses_managed_header_footer => true) }

        it "should not validate staged header or staged footer" do
          html_with_script = <<-HTML
            <script src="http://cdn.agency.gov/script.js"></script>
            <h1>html with script</h1>
          HTML
          affiliate.is_updating_staged_header_footer = true
          affiliate.update_attributes(:staged_header => html_with_script, :staged_footer => html_with_script).should be_true
        end
      end

      context "site does not use staged one serp" do
        let(:affiliate) { Affiliate.create!(:display_name => 'test header footer validation',
                                            :uses_one_serp => false,
                                            :staged_uses_one_serp => false) }

        it "should not validate staged header or staged footer" do
          html_with_script = <<-HTML
            <script src="http://cdn.agency.gov/script.js"></script>
            <h1>html with script</h1>
          HTML
          affiliate.update_attributes(:staged_header => html_with_script, :staged_footer => html_with_script).should be_true
        end
      end
    end

    context "is_updating_staged_header_footer is set to false" do
      let(:affiliate) { Affiliate.create!(:display_name => 'test header footer validation',
                                          :uses_one_serp => true,
                                          :staged_uses_one_serp => true,
                                          :uses_managed_header_footer => false,
                                          :staged_uses_managed_header_footer => false) }
      it "should allow script, style or link elements in staged header or staged footer" do
        affiliate.is_updating_staged_header_footer = false

        html_with_script = <<-HTML
            <script src="http://cdn.agency.gov/script.js"></script>
            <h1>html with script</h1>
        HTML
        affiliate.update_attributes(:staged_header => html_with_script, :staged_footer => html_with_script).should be_true
      end
    end
  end

  describe "#update_attributes_for_staging" do
    it "should set has_staged_content to true and receive update_attributes" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      attributes = mock('attributes')
      attributes.should_receive(:has_key?).with(:staged_uses_managed_header_footer).and_return(false)
      attributes.should_receive(:[]).with(:staged_header_image).and_return(nil)
      attributes.should_receive(:[]).with(:mark_staged_header_image_for_deletion).and_return(nil)
      attributes.should_receive(:[]=).with(:has_staged_content, true)
      return_value = mock('return value')
      affiliate.should_receive(:update_attributes).with(attributes).and_return(return_value)
      affiliate.update_attributes_for_staging(attributes).should == return_value
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
          attributes = { :staged_header_image => mock('new staged header image') }
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
          attributes = { :staged_header_image => '' }
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
          attributes = { :mark_staged_header_image_for_deletion => '1' }
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
          attributes = { :mark_staged_header_image_for_deletion => '0' }
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
        attributes = { :staged_header_image => mock('new staged header image') }
        affiliate.should_receive(:update_attributes).with(attributes).and_return(true)

        affiliate.update_attributes_for_staging(attributes).should be_true
      end
    end

    context "when attributes contain staged_uses_managed_header_footer" do
      it "should set is_updating_staged_header_footer to true" do
        affiliate = Affiliate.create!(@valid_create_attributes)
        affiliate.should_receive(:is_updating_staged_header_footer=).with(true)
        affiliate.update_attributes_for_staging(:staged_header => 'staged header', :staged_footer => 'staged footer', :staged_uses_managed_header_footer => false)
      end
    end

    context "when attributes does not contain staged_uses_managed_header_footer" do
      it "should set is_updating_staged_header_footer to false" do
        affiliate = Affiliate.create!(@valid_create_attributes)
        affiliate.should_not_receive(:is_updating_staged_header_footer=)
        affiliate.update_attributes_for_staging(:staged_theme => 'elegant')
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

    context "when attributes contain staged_uses_managed_header_footer" do
      it "should set is_updating_staged_header_footer to true" do
        affiliate.should_receive(:is_updating_staged_header_footer=).with(true)
        affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer', :staged_uses_managed_header_footer => false)
      end
    end

    context "when attributes does not contain staged_uses_managed_header_footer" do
      it "should set is_updating_staged_header_footer to false" do
        affiliate.should_not_receive(:is_updating_staged_header_footer=)
        affiliate.update_attributes_for_live(:staged_theme => 'elegant')
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
      let(:css_property_hash) { { :title_link_color => '#33ff33', :visited_title_link_color => '#0000ff' }.reverse_merge(Affiliate::DEFAULT_CSS_PROPERTIES) }
      let(:affiliate) { Affiliate.create!(@valid_create_attributes.merge(:theme => 'custom', :css_property_hash => css_property_hash)) }

      specify { affiliate.css_property_hash(true).should == css_property_hash }
    end

    context "when theme is not custom" do
      let(:css_property_hash) { { :font_family => Affiliate::FONT_FAMILIES.last } }
      let(:affiliate) { Affiliate.create!(
          @valid_create_attributes.merge(:theme => 'elegant',
                                         :css_property_hash => css_property_hash)) }

      specify { affiliate.css_property_hash(true).should == Affiliate::THEMES[:elegant].reverse_merge(css_property_hash) }
    end
  end

  describe "#staged_css_property_hash" do
    context "when theme is custom" do
      let(:staged_css_property_hash) { { :title_link_color => '#33ff33', :visited_title_link_color => '#0000ff' }.reverse_merge(Affiliate::DEFAULT_CSS_PROPERTIES) }
      let(:affiliate) { Affiliate.create!(@valid_create_attributes.merge(:theme => 'natural', :staged_theme => 'custom', :staged_css_property_hash => staged_css_property_hash)) }

      specify { affiliate.staged_css_property_hash(true).should == staged_css_property_hash }
    end

    context "when theme is not custom" do
      let(:staged_css_property_hash) { { :font_family => Affiliate::FONT_FAMILIES.last } }
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

  describe "#check_domains_for_live_code" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @affiliate.site_domains.destroy_all
      @affiliate.site_domains << SiteDomain.new(:domain => '.gov')
      @affiliate.site_domains << SiteDomain.new(:domain => 'hasthecode.usa.gov')
      @affiliate.site_domains << SiteDomain.new(:domain => 'alsohasthecode.usa.gov')
      @affiliate.site_domains << SiteDomain.new(:domain => 'doesnothavethecode.usa.gov')
      @affiliate.live_fields_json = "{\"managed_header_text\":\"hasthecodetoo.usa.gov\"}"
      page_with_code = File.read(Rails.root.to_s + '/spec/fixtures/html/page_with_search_code.html')
      page_without_code = File.read(Rails.root.to_s + '/spec/fixtures/html/page_without_search_code.html')
      Kernel.stub!(:open).and_return(page_with_code, page_with_code, page_without_code, page_with_code)
    end

    it "should output a list of domains separated by semi-colons of all domains that have our search code, ignoring any TLDs" do
      @affiliate.check_domains_for_live_code.should == 'hasthecode.usa.gov;alsohasthecode.usa.gov;hasthecodetoo.usa.gov'
    end

    context "when some kind of error occurs fetching a page" do
      before do
        Kernel.stub!(:open).and_raise OpenURI::HTTPError.new("400 Bad Request", nil)
      end

      it "should return an empty result" do
        @affiliate.check_domains_for_live_code.should == ''
      end
    end

    context "when a timeout error occurs" do
      before do
        Kernel.stub!(:open).and_raise Timeout::Error
      end

      it "should return an empty result" do
        @affiliate.check_domains_for_live_code.should == ''
      end
    end
  end

  describe "#refresh_indexed_documents" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @affiliate.fetch_concurrency = 2
      @first = @affiliate.indexed_documents.build(:url => 'http://some.mil/')
      @second = @affiliate.indexed_documents.build(:url => 'http://some.mil/foo')
      @third = @affiliate.indexed_documents.build(:url => 'http://some.mil/bar')
      @affiliate.save!
    end

    it "should enqueue in batches" do
      Resque.should_receive(:enqueue_with_priority).with(:low, AffiliateIndexedDocumentFetcher, @affiliate.id, @first.id, @second.id)
      Resque.should_receive(:enqueue_with_priority).with(:low, AffiliateIndexedDocumentFetcher, @affiliate.id, @third.id, @third.id)
      @affiliate.refresh_indexed_documents
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
end
