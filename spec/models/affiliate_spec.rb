# coding: utf-8
require 'spec_helper'

describe Affiliate do
  fixtures :users, :affiliates, :site_domains, :features, :youtube_profiles, :memberships, :languages

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
    describe 'columns' do
      it do
        is_expected.to have_db_column(:i14y_date_stamp_enabled).
          of_type(:boolean).with_options(default: false, null: false)
      end
      # The active_template_id column has been deprectated. It will be dropped in a future migration.
      it { is_expected.to have_db_column(:active_template_id).of_type(:integer) }
      it { is_expected.to have_db_column(:template_id).of_type(:integer) }
      it do
        is_expected.to have_db_column(:search_engine).of_type(:string).
          with_options(default: 'BingV7', null: false)
      end
      it do
        is_expected.to have_db_column(:active).of_type(:boolean).
          with_options(default: true, null: false)
      end
    end

    describe 'indices' do
      it { is_expected.to have_db_index(:active_template_id) }
      it { is_expected.to have_db_index(:template_id) }
    end

    describe 'Paperclip attachments' do
      it { is_expected.to have_attached_file :page_background_image }
      it { is_expected.to have_attached_file :header_image }
      it { is_expected.to have_attached_file :mobile_logo }
      it { is_expected.to have_attached_file :header_tagline_logo }
    end
  end

  describe "Creating new instance of Affiliate" do
    it { is_expected.to validate_presence_of :display_name }
    Language.pluck(:code).each do |locale|
      it { is_expected.to allow_value(locale).for(:locale) }
    end
    it { is_expected.to validate_presence_of :locale }
    it { is_expected.to validate_uniqueness_of(:api_access_key).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(33) }
    ["<IMG SRC=", "259771935505'", "spacey name"].each do |value|
      it { is_expected.not_to allow_value(value).for(:name) }
    end
    %w{data.gov ct-new some_aff 123 NewAff}.each do |value|
      it { is_expected.to allow_value(value).for(:name) }
    end
    it { is_expected.to validate_attachment_size(:page_background_image).in(1..512.kilobytes) }
    it { is_expected.to validate_attachment_size(:header_image).in(1..512.kilobytes) }
    it { is_expected.to validate_attachment_size(:mobile_logo).in(1..64.kilobytes) }
    it { is_expected.to validate_attachment_size(:header_tagline_logo).in(1..16.kilobytes) }

    %i{ page_background_image header_image header_tagline_logo mobile_logo }.each do |image|
          it { is_expected.to validate_attachment_content_type(image).
               allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).
               rejecting(nil, %w{ text/plain text/xml application/pdf }) }
    end

    it { is_expected.to validate_inclusion_of(:search_engine).in_array(%w( Google BingV6 BingV7 SearchGov )) }

    it { is_expected.to have_many :boosted_contents }
    it { is_expected.to have_many :sayt_suggestions }
    it { is_expected.to have_many :twitter_profiles }

    it { is_expected.to have_many(:routed_query_keywords).through :routed_queries }
    it { is_expected.to have_many(:rss_feed_urls).through :rss_feeds }
    it { is_expected.to have_many(:users).through :memberships }

    it { is_expected.to have_many(:affiliate_feature_addition).dependent(:destroy) }
    it { is_expected.to have_many(:affiliate_twitter_settings).dependent(:destroy) }
    it { is_expected.to have_many(:excluded_domains).dependent(:destroy) }
    it { is_expected.to have_many(:featured_collections).dependent(:destroy) }
    it { is_expected.to have_many(:features).dependent(:destroy) }
    it { is_expected.to have_many(:flickr_profiles).dependent(:destroy) }
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:navigations).dependent(:destroy) }
    it { is_expected.to have_many(:routed_queries).dependent(:destroy) }
    it { is_expected.to have_many(:rss_feeds).dependent(:destroy) }
    it { is_expected.to have_many(:affiliate_templates).dependent(:destroy) }
    it { is_expected.to have_many(:available_templates).through(:affiliate_templates).source(:template) }
    it { is_expected.to have_many(:site_domains).dependent(:destroy) }
    it { is_expected.to have_many(:tag_filters).dependent(:destroy) }

    it { is_expected.to have_and_belong_to_many :instagram_profiles }
    it { is_expected.to have_and_belong_to_many :youtube_profiles }

    it { is_expected.to belong_to :agency }
    it { is_expected.to belong_to :language }
    it { is_expected.to belong_to :template }

    it { is_expected.to validate_attachment_content_type(:page_background_image).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }
    it { is_expected.to validate_attachment_content_type(:header_image).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }
    it { is_expected.to validate_attachment_content_type(:mobile_logo).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }

    it "should create a new instance given valid attributes" do
      Affiliate.create!(valid_create_attributes)
    end

    it "should downcase the name if it's uppercase" do
      affiliate = Affiliate.new(valid_create_attributes)
      affiliate.name = 'AffiliateSite'
      affiliate.save!
      expect(affiliate.name).to eq("affiliatesite")
    end

    describe "on create" do
      it "should update css_properties with json string from css property hash" do
        css_property_hash = {'title_link_color' => '#33ff33', 'visited_title_link_color' => '#0000ff'}
        affiliate = Affiliate.create!(valid_create_attributes.merge(:css_property_hash => css_property_hash))
        expect(JSON.parse(affiliate.css_properties, :symbolize_names => true)[:title_link_color]).to eq('#33ff33')
        expect(JSON.parse(affiliate.css_properties, :symbolize_names => true)[:visited_title_link_color]).to eq('#0000ff')
      end

      it "should normalize site domains" do
        affiliate = Affiliate.create!(valid_create_attributes.merge(
                                          site_domains_attributes: { '0' => { domain: 'www1.usa.gov' },
                                                                     '1' => { domain: 'www2.usa.gov' },
                                                                     '2' => { domain: 'usa.gov' } }))
        expect(affiliate.site_domains(true).count).to eq(1)
        expect(affiliate.site_domains.first.domain).to eq('usa.gov')

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
        expect(affiliate.is_medline_govbox_enabled).to eq(false)
      end

      it "should have SAYT enabled by default" do
        expect(Affiliate.create!(valid_create_attributes).is_sayt_enabled).to be true
      end

      it 'should generate a database-level error when attempting to add an ' \
         'affiliate with the same name as an existing affiliate, but with ' \
         'different case; instead it should return false' do
        affiliate = Affiliate.new(valid_attributes)
        affiliate.name = valid_attributes[:name]
        affiliate.save!
        duplicate_affiliate = Affiliate.new(valid_attributes)
        duplicate_affiliate.name = valid_attributes[:name].upcase
        expect(duplicate_affiliate.save).to be false
      end

      it "should populate default search label for English site" do
        affiliate = Affiliate.create!(valid_attributes.merge(locale: 'en'))
        expect(affiliate.default_search_label).to eq('Everything')
      end

      it "should populate default search labels for Spanish site" do
        affiliate = Affiliate.create!(valid_attributes.merge(locale: 'es'))
        expect(affiliate.default_search_label).to eq('Todo')
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
      expect(Affiliate.find(affiliate.id).css_property_hash[:page_background_color]).to eq(Affiliate::THEMES[:default][:page_background_color])
    end

    it "should save favicon URL with http:// prefix when it does not start with http(s)://" do
      url = 'cdn.agency.gov/favicon.ico'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        affiliate.update_attributes!(favicon_url: "#{prefix}#{url}")
        expect(affiliate.favicon_url).to eq("http://#{prefix}#{url}")
      end
    end

    it "should save favicon URL as is when it starts with http(s)://" do
      url = 'cdn.agency.gov/favicon.ico'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        affiliate.update_attributes(favicon_url: "#{prefix}#{url}")
        expect(affiliate.favicon_url).to eq("#{prefix}#{url}")
      end
    end

    it "should save external CSS URL with http:// prefix when it does not start with http(s)://" do
      url = 'cdn.agency.gov/custom.css'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        affiliate.update_attributes!(:external_css_url => "#{prefix}#{url}")
        expect(affiliate.external_css_url).to eq("http://#{prefix}#{url}")
      end
    end

    it "should save external CSS URL as is when it starts with http(s)://" do
      url = 'cdn.agency.gov/custom.css'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        affiliate.update_attributes!(:external_css_url => "#{prefix}#{url}")
        expect(affiliate.external_css_url).to eq("#{prefix}#{url}")
      end
    end

    it 'should prefix website with http://' do
      affiliate.update_attributes!(website: 'usa.gov')
      expect(affiliate.website).to eq('http://usa.gov')
    end

    it "should set css properties" do
      affiliate.css_property_hash = { font_family: 'Verdana, sans-serif' }
      affiliate.save!
      expect(Affiliate.find(affiliate.id).css_property_hash[:font_family]).to eq('Verdana, sans-serif')
    end

    it "should not set header_footer_nested_css fields" do
      affiliate.update_attributes!(staged_header_footer_css: '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }', header_footer_css: '')
      expect(affiliate.staged_nested_header_footer_css).to be_blank
      expect(affiliate.header_footer_css).to be_blank
      affiliate.update_attributes!(staged_header_footer_css: '', header_footer_css: '@charset "UTF-8"; @import url("other.css"); live.h1 { color: red }')
      expect(affiliate.staged_nested_header_footer_css).to be_blank
      expect(affiliate.nested_header_footer_css).to be_blank
    end

    it "should set previous json fields" do
      affiliate.previous_header = 'previous header'
      affiliate.previous_footer = 'previous footer'
      affiliate.save!
      expect(Affiliate.find(affiliate.id).previous_header).to eq('previous header')
      expect(Affiliate.find(affiliate.id).previous_footer).to eq('previous footer')
    end

    it "should set staged and live json fields" do
      affiliate.header = 'live header'
      affiliate.footer = 'live footer'
      affiliate.staged_header = 'staged header'
      affiliate.staged_footer = 'staged footer'
      affiliate.save!
      expect(Affiliate.find(affiliate.id).header).to eq('live header')
      expect(Affiliate.find(affiliate.id).footer).to eq('live footer')
      expect(Affiliate.find(affiliate.id).staged_header).to eq('staged header')
      expect(Affiliate.find(affiliate.id).staged_footer).to eq('staged footer')
    end

    it 'should populate search labels for English site' do
      english_affiliate = Affiliate.create!(valid_attributes.merge(locale: 'en'))
      english_affiliate.default_search_label = ''
      english_affiliate.save!
      expect(english_affiliate.default_search_label).to eq('Everything')
    end

    it "should populate search labels for Spanish site" do
      spanish_affiliate = Affiliate.create!(valid_attributes.merge(locale: 'es'))
      spanish_affiliate.default_search_label = ''
      spanish_affiliate.save!
      expect(spanish_affiliate.default_search_label).to eq('Todo')
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
      expect(en_affiliate.rss_govbox_label).to eq('News')
      en_affiliate.update_attributes!(rss_govbox_label: '')
      expect(en_affiliate.rss_govbox_label).to eq('News')

      es_affiliate = Affiliate.create!(valid_create_attributes.merge(locale: 'es', name: 'es-site'))
      expect(es_affiliate.rss_govbox_label).to eq('Noticias')
      es_affiliate.update_attributes!({ rss_govbox_label: '' })
      expect(es_affiliate.rss_govbox_label).to eq('Noticias')
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
        expect(Affiliate.find(affiliate.id).staged_header.squish).to eq(html_without_comments.squish)
        expect(Affiliate.find(affiliate.id).staged_footer.squish).to eq(html_without_comments.squish)
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
      expect(Affiliate.find(affiliate.id).connections.count).to eq(1)
      connected_affiliate.destroy
      expect(Affiliate.find(affiliate.id).connections.count).to eq(0)
    end
  end

  describe "validations" do
    it "should be valid when FONT_FAMILIES includes font_family in css property hash" do
      FontFamily::ALL.each do |font_family|
        expect(Affiliate.new(valid_create_attributes.merge(:css_property_hash => {'font_family' => font_family}))).to be_valid
      end
    end

    it "should not be valid when FONT_FAMILIES does not include font_family in css property hash" do
      expect(Affiliate.new(valid_create_attributes.merge(:css_property_hash => {'font_family' => 'Comic Sans MS'}))).not_to be_valid
    end

    it "should be valid when color property in css property hash consists of a # character followed by 3 or 6 hexadecimal digits " do
      %w{ #333 #FFF #fff #12F #666666 #666FFF #FFFfff #ffffff }.each do |valid_color|
        css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({'left_tab_text_color' => "#{valid_color}",
                                                                          'title_link_color' => "#{valid_color}",
                                                                          'visited_title_link_color' => "#{valid_color}",
                                                                          'description_text_color' => "#{valid_color}",
                                                                          'url_link_color' => "#{valid_color}"})
        expect(Affiliate.new(valid_create_attributes.merge(:css_property_hash => css_property_hash))).to be_valid
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
        expect(affiliate).not_to be_valid
        expect(affiliate.errors[:base]).to include("Title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
        expect(affiliate.errors[:base]).to include("Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
        expect(affiliate.errors[:base]).to include("Description text color should consist of a # character followed by 3 or 6 hexadecimal digits")
        expect(affiliate.errors[:base]).to include("Url link color should consist of a # character followed by 3 or 6 hexadecimal digits")
      end
    end

    it "should validate color property in staged css property hash" do
      css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({'title_link_color' => 'invalid', 'visited_title_link_color' => '#DDDD'})
      affiliate = Affiliate.new(valid_create_attributes.merge(:css_property_hash => css_property_hash))
      expect(affiliate.save).to be false
      expect(affiliate.errors[:base]).to include("Title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
      expect(affiliate.errors[:base]).to include("Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits")
    end

    it 'validates logo alignment' do
      expect(Affiliate.new(valid_create_attributes.merge(
                        css_property_hash: { 'logo_alignment' => 'invalid' }))).not_to be_valid
    end

    it "should not validate header_footer_css" do
      affiliate = Affiliate.new(valid_create_attributes.merge(:header_footer_css => "h1 { invalid-css-syntax }"))
      expect(affiliate.save).to be true

      affiliate = Affiliate.new(valid_create_attributes.merge(:header_footer_css => "h1 { color: #DDDD }", name: 'anothersite'))
      expect(affiliate.save).to be true
    end

    it "should not validate staged_header_footer_css for invalid css property value" do
      affiliate = Affiliate.new(valid_create_attributes.merge(staged_header_footer_css: 'h1 { invalid-css-syntax }'))
      expect(affiliate.save).to be true

      affiliate = Affiliate.new(valid_create_attributes.merge(staged_header_footer_css: 'h1 { color: #DDDD }', name: 'anothersite'))
      expect(affiliate.save).to be true
    end

    it 'validates locale is valid' do
      affiliate = Affiliate.new(valid_create_attributes.merge(locale: 'invalid_locale'))
      expect(affiliate.save).to be false
      expect(affiliate.errors[:base]).to include("Locale must be valid")
    end

    describe 'bing v5 key stripping' do
      subject { Affiliate.new(valid_create_attributes.merge(bing_v5_key: bing_v5_key)) }
      before { subject.save }

      [
        nil,
        '',
        '    ',
      ].each do |blank_key|
        context "when given a blank key '#{blank_key}'" do
          let(:bing_v5_key) { blank_key }

          it 'sets it to nil' do
            expect(subject.bing_v5_key).to be nil
          end
        end
      end

      {
        '  foo  '                             => 'foo',
        ' da076306990394a250f5f2ecd8cfc323  ' => 'da076306990394a250f5f2ecd8cfc323',
      }.each do |initial_value, result|
        context "when given a space-padded key '#{initial_value}'" do
          let(:bing_v5_key) { initial_value }

          it "strips it to '#{result}'" do
            expect(subject.bing_v5_key).to eql(result)
          end
        end
      end
    end

    describe 'bing v5 key validation' do
      subject { Affiliate.new(valid_create_attributes.merge(bing_v5_key: bing_v5_key)) }

      [
        nil,
        'da076306990394a250f5f2ecd8cfc323',
        '961546ffc05c341247ec71e38459820a',
        '50e4b73b2e11f25377fd088d0154c50a',
        '27b0bb273f48f29f8683e9a9a2285e70',
      ].each do |valid_bing_v5_key|
        context "when given valid key '#{valid_bing_v5_key}'" do
          let(:bing_v5_key) { valid_bing_v5_key }

          it 'validates bing_v5_key is valid' do
            expect(subject.save).to be true
          end
        end
      end

      %w[
        lolkey
        abc123
        somestringthatis32charsbutnothex
      ].each do |invalid_bing_v5_key|
        context "when given invalid key '#{invalid_bing_v5_key}'" do
          let(:bing_v5_key) { invalid_bing_v5_key }

          it 'validates bing_v5_key is not valid' do
            expect(subject.save).to be false
            expect(subject.errors[:bing_v5_key]).to include('is invalid')
          end
        end
      end
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
        expect(affiliate.update_attributes(:staged_header => html_with_script, :staged_footer => html_with_script)).to be false
        expect(affiliate.errors[:base].join).to match(/#{header_error_message}/)
        expect(affiliate.errors[:base].join).to match(/#{footer_error_message}/)

        html_with_style = <<-HTML
            <style>#my_header { color:red }</style>
            <h1>html with style</h1>
        HTML
        expect(affiliate.update_attributes(:staged_header => html_with_style, :staged_footer => html_with_style)).to be false
        expect(affiliate.errors[:base].join).to match(/#{header_error_message}/)
        expect(affiliate.errors[:base].join).to match(/#{footer_error_message}/)

        html_with_link = <<-HTML
            <link href="http://cdn.agency.gov/link.css" />
            <h1>html with link</h1>
        HTML
        expect(affiliate.update_attributes(:staged_header => html_with_link, :staged_footer => html_with_link)).to be false
        expect(affiliate.errors[:base].join).to match(/#{header_error_message}/)
        expect(affiliate.errors[:base].join).to match(/#{footer_error_message}/)

        html_with_form = <<-HTML
            <form></form>
            <h1>html with link</h1>
        HTML
        expect(affiliate.update_attributes(:staged_header => html_with_form, :staged_footer => html_with_form)).to be false
        expect(affiliate.errors[:base].join).to match(/#{header_error_message}/)
        expect(affiliate.errors[:base].join).to match(/#{footer_error_message}/)
      end

      it 'should not allow onload attribute in staged header or staged footer' do
        header_error_message = %q(HTML to customize the top of your search results page must not contain the onload attribute)
        footer_error_message = %q(HTML to customize the bottom of your search results page must not contain the onload attribute)

        html_with_onload = <<-HTML
          <div onload="cdn.agency.gov/script.js"></div>
          <h1>html with onload</h1>
        HTML

        expect(affiliate.update_attributes(:staged_header => html_with_onload, :staged_footer => html_with_onload)).to be false
        expect(affiliate.errors[:base].join).to match(/#{header_error_message}/)
        expect(affiliate.errors[:base].join).to match(/#{footer_error_message}/)
      end

      it "should not allow malformed HTML in staged header or staged footer" do
        header_error_message = 'HTML to customize the top of your search results is invalid'
        footer_error_message = 'HTML to customize the bottom of your search results is invalid'

        html_with_body = <<-HTML
            <html><body><h1>html with script</h1></body></html>
        HTML
        expect(affiliate.update_attributes(:staged_header => html_with_body, :staged_footer => html_with_body)).to be false
        expect(affiliate.errors[:base].join).to include("#{header_error_message}")
        expect(affiliate.errors[:base].join).to include("#{footer_error_message}")

        malformed_html_fragments = <<-HTML
            <link href="http://cdn.agency.gov/link.css"></script>
            <h1>html with link</h1>
        HTML
        expect(affiliate.update_attributes(:staged_header => malformed_html_fragments, :staged_footer => malformed_html_fragments)).to be false
        expect(affiliate.errors[:base].join).to include("#{header_error_message}")
        expect(affiliate.errors[:base].join).to include("#{footer_error_message}")
      end

      it "should not validate header_footer_css" do
        expect(affiliate.update_attributes(:header_footer_css => "h1 { invalid-css-syntax }")).to be true
        expect(affiliate.update_attributes(:header_footer_css => "h1 { color: #DDDD }")).to be true
      end

      it "should validate staged_header_footer_css for invalid css property value" do
        expect(affiliate.update_attributes(:staged_header_footer_css => "h1 { invalid-css-syntax }")).to be false
        expect(affiliate.errors[:base].first).to match(/Invalid CSS/)

        expect(affiliate.update_attributes(:staged_header_footer_css => "h1 { color: #DDDD }")).to be false
        expect(affiliate.errors[:base].first).to match(/Colors must have either three or six digits/)
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
        expect(affiliate.update_attributes(:staged_header => html_with_script, :staged_footer => html_with_script)).to be true
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
      attributes = double('attributes')
      expect(attributes).to receive(:[]).with(:staged_uses_managed_header_footer).and_return('0')
      expect(attributes).to receive(:[]=).with(:has_staged_content, true)
      return_value = double('return value')
      expect(affiliate).to receive(:update_attributes).with(attributes).and_return(return_value)
      expect(affiliate.update_attributes_for_staging(attributes)).to eq(return_value)
    end

    context "when attributes contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to true" do
        affiliate = Affiliate.create!(display_name: 'oneserp affiliate', name: 'oneserpaffiliate')
        expect(affiliate).to receive(:is_validate_staged_header_footer=).with(true)
        affiliate.update_attributes_for_staging(:staged_uses_managed_header_footer => '0',
                                                :staged_header => 'staged header',
                                                :staged_footer => 'staged footer')
      end

      it "should set header_footer_nested_css fields" do
        affiliate = Affiliate.create!(valid_create_attributes)
        affiliate.update_attributes!(:header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }')
        expect(affiliate.update_attributes_for_staging(
          :staged_uses_managed_header_footer => '0',
          :staged_header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }')).to be true
        expect(affiliate.staged_nested_header_footer_css.squish).to match(/^#{Regexp.escape('.header-footer h1{color:blue}')}$/)
      end

      it 'should not validated live header_footer_css field' do
        affiliate = Affiliate.create!(valid_create_attributes)
        affiliate.update_attributes!(:header_footer_css => 'h1 { invalid-css-syntax }')
        expect(affiliate.update_attributes_for_staging(
          :staged_uses_managed_header_footer => '0',
          :staged_header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }')).to be true
        expect(affiliate.staged_nested_header_footer_css.squish).to match(/^#{Regexp.escape('.header-footer h1{color:blue}')}$/)
      end
    end

    context "when attributes does not contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to false" do
        affiliate = Affiliate.create!(display_name: 'oneserp affiliate', name: 'oneserpaffiliate')
        expect(affiliate).to receive(:is_validate_staged_header_footer=).with(false)
        affiliate.update_attributes_for_staging(staged_uses_managed_header_footer: '1')
      end
    end
  end

  describe "#update_attributes_for_live" do
    let(:affiliate) { Affiliate.create!(valid_create_attributes.merge(:header => 'old header', :footer => 'old footer')) }

    context "when successfully update_attributes" do
      before do
        expect(affiliate).to receive(:update_attributes).and_return(true)
      end

      it "should set previous fields" do
        expect(affiliate).to receive(:previous_header=).with('old header')
        expect(affiliate).to receive(:previous_footer=).with('old footer')
        expect(affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer')).to be true
      end

      it "should set attributes from staged to live" do
        expect(affiliate).to receive(:set_attributes_from_staged_to_live)
        expect(affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer')).to be true
      end

      it "should set has_staged_content to false" do
        expect(affiliate).to receive(:has_staged_content=).with(false)
        expect(affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer')).to be true
      end

      it "should save!" do
        expect(affiliate).to receive(:save!)
        expect(affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer')).to be true
      end
    end

    context "when update_attributes failed" do
      before do
        expect(affiliate).to receive(:update_attributes).and_return(false)
        expect(affiliate).not_to receive(:previous_header=)
        expect(affiliate).not_to receive(:previous_footer=)
        expect(affiliate).not_to receive(:save!)
      end

      specify { expect(affiliate.update_attributes_for_live(:staged_header => 'staged header', :staged_footer => 'staged footer')).to be false }
    end

    context "when attributes contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to true" do
        expect(affiliate).to receive(:is_validate_staged_header_footer=).with(true)
        affiliate.update_attributes_for_live(:staged_uses_managed_header_footer => '0',
                                             :staged_header => 'staged header',
                                             :staged_footer => 'staged footer')
      end

      it "should set header_footer_nested_css fields" do
        affiliate = Affiliate.create!(valid_create_attributes)
        expect(affiliate.update_attributes_for_live(
          :staged_uses_managed_header_footer => '0',
          :staged_header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }')).to be true
        expect(affiliate.staged_nested_header_footer_css.squish).to match(/^#{Regexp.escape('.header-footer h1{color:blue}')}$/)
        expect(affiliate.nested_header_footer_css.squish).to match(/^#{Regexp.escape('.header-footer h1{color:blue}')}$/)
      end

      it 'should not validated live header_footer_css field' do
        affiliate = Affiliate.create!(valid_create_attributes)
        affiliate.update_attributes!(:header_footer_css => 'h1 { invalid-css-syntax }')
        expect(affiliate.update_attributes_for_live(
          :staged_uses_managed_header_footer => '0',
          :staged_header_footer_css => '@charset "UTF-8"; @import url("other.css"); h1 { color: blue }')).to be true
        expect(affiliate.staged_nested_header_footer_css.squish).to match(/^#{Regexp.escape('.header-footer h1{color:blue}')}$/)
        expect(affiliate.nested_header_footer_css.squish).to match(/^#{Regexp.escape('.header-footer h1{color:blue}')}$/)
      end
    end

    context "when attributes does not contain staged_uses_managed_header_footer='0'" do
      it "should set is_validate_staged_header_footer to false" do
        expect(affiliate).to receive(:is_validate_staged_header_footer=).with(false)
        affiliate.update_attributes_for_live(staged_uses_managed_header_footer: '1')
      end
    end
  end

  describe "#set_attributes_from_staged_to_live" do
    let(:affiliate) { Affiliate.create!(valid_create_attributes) }

    it "should set live fields with values from staged fields" do
      Affiliate::ATTRIBUTES_WITH_STAGED_AND_LIVE.each do |attribute|
        staged_value = double("staged_value for #{attribute}")
        expect(affiliate).to receive("staged_#{attribute}".to_sym).and_return(staged_value)
        expect(affiliate).to receive("#{attribute}=".to_sym).with(staged_value)
      end
      affiliate.set_attributes_from_staged_to_live
    end
  end

  describe "#set_attributes_from_live_to_staged" do
    let(:affiliate) { Affiliate.create!(valid_create_attributes) }

    it "should set staged fields with values from live fields" do
      Affiliate::ATTRIBUTES_WITH_STAGED_AND_LIVE.each do |attribute|
        live_value = double("live_value for #{attribute}")
        expect(affiliate).to receive("#{attribute}".to_sym).and_return(live_value)
        expect(affiliate).to receive("staged_#{attribute}=".to_sym).with(live_value)
      end
      affiliate.set_attributes_from_live_to_staged
    end
  end

  describe '.human_attribute_name' do
    specify { expect(Affiliate.human_attribute_name('display_name')).to eq('Display name') }
    specify { expect(Affiliate.human_attribute_name('name')).to eq('Site Handle (visible to searchers in the URL)') }
  end

  describe "#push_staged_changes" do
    it "should set attributes from staged to live fields, set has_staged_content to false and save!" do
      affiliate = Affiliate.create!(valid_create_attributes)
      expect(affiliate).to receive(:set_attributes_from_staged_to_live)
      expect(affiliate).to receive(:has_staged_content=).with(false)
      expect(affiliate).to receive(:save!)
      affiliate.push_staged_changes
    end
  end

  describe "#cancel_staged_changes" do
    it "should set attributes from live to staged fields, set has_staged_content to false and save!" do
      affiliate = Affiliate.create!(valid_create_attributes)
      expect(affiliate).to receive(:set_attributes_from_live_to_staged)
      expect(affiliate).to receive(:has_staged_content=).with(false)
      expect(affiliate).to receive(:save!)
      affiliate.cancel_staged_changes
    end

    it 'should copy header_footer_css' do
      affiliate = Affiliate.create!(valid_create_attributes)
      affiliate.update_attributes!(:header_footer_css => 'h1 { invalid-css-syntax }',
                                   :nested_header_footer_css => '.header_footer h1 { invalid-css-syntax }')
      Affiliate.find(affiliate.id).cancel_staged_changes

      aff_after_cancel = Affiliate.find(affiliate.id)
      expect(aff_after_cancel.staged_header_footer_css).to eq('h1 { invalid-css-syntax }')
      expect(aff_after_cancel.staged_nested_header_footer_css).to eq('.header_footer h1 { invalid-css-syntax }')
    end
  end

  describe "#ordered" do
    it "should include a scope called 'ordered'" do
      expect(Affiliate.ordered).not_to be_nil
    end
  end

  describe "#sync_staged_attributes" do
    context "when the affiliate has staged content" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      before do
        expect(affiliate).to receive(:has_staged_content?).and_return(false)
        expect(affiliate).to receive(:cancel_staged_changes).and_return(true)
      end

      specify { expect(affiliate.sync_staged_attributes).to be true }
    end

    context "when the affiliate does not have staged content" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      before do
        expect(affiliate).to receive(:has_staged_content?).and_return(true)
        expect(affiliate).not_to receive(:cancel_staged_changes)
      end

      specify { expect(affiliate.sync_staged_attributes).to be_nil }
    end
  end

  describe "#has_multiple_domains?" do
    let(:affiliate) { Affiliate.create!(valid_create_attributes) }

    context "when Affiliate has more than 1 domain" do
      before do
        affiliate.add_site_domains('foo.gov' => nil, 'bar.gov' => nil)
      end

      specify { expect(affiliate).to have_multiple_domains }
    end

    context "when Affiliate has no domain" do
      specify { expect(affiliate).not_to have_multiple_domains }
    end

    context "when Affiliate has 1 domain" do
      before do
        affiliate.add_site_domains('foo.gov' => nil)
      end
      specify { expect(affiliate).not_to have_multiple_domains }
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
      expect(affiliate.recent_user_activity.utc.to_s).to eq(recent_time.utc.to_s)
    end
  end

  describe "#has_no_social_image_feeds?" do
    let(:affiliate) { affiliates(:basic_affiliate) }

    context 'when affiliate has no ASIS profiles' do
      before do
        affiliate.flickr_profiles.delete_all
        affiliate.instagram_profiles.delete_all
        affiliate.rss_feeds.mrss.delete_all
      end
      specify { expect(affiliate).to have_no_social_image_feeds }
    end

    context 'when affiliate has MRSS feed but the RSS feed URL has no Oasis MRSS name' do
      before do
        affiliate.flickr_profiles.delete_all
        affiliate.instagram_profiles.delete_all
        affiliate.rss_feeds.mrss.delete_all
        feed = affiliate.rss_feeds.build(name: "mrss", show_only_media_content: true)
        feed.rss_feed_urls.build(url: "http://www.defense.gov/news/mrss_leadphotos.xml", last_crawl_status: 'OK',
                                 oasis_mrss_name: nil, rss_feed_owner_type: "Affiliate")
        allow(feed.rss_feed_urls.first).to receive(:url_must_point_to_a_feed) { true }
        feed.save!
      end
      specify { expect(affiliate).to have_no_social_image_feeds }
    end
  end

  describe "#css_property_hash" do
    context "when theme is custom" do
      let(:css_property_hash) { {:title_link_color => '#33ff33', :visited_title_link_color => '#0000ff'}.reverse_merge(Affiliate::DEFAULT_CSS_PROPERTIES) }
      let(:affiliate) { Affiliate.create!(valid_create_attributes.merge(:theme => 'custom', :css_property_hash => css_property_hash)) }

      specify { expect(affiliate.css_property_hash(true)).to eq(css_property_hash) }
    end

    context 'when theme is default' do
      let(:css_property_hash) { { font_family: FontFamily::ALL.last } }
      let(:affiliate) { Affiliate.create!(
        valid_create_attributes.merge(theme: 'default',
                                       css_property_hash: css_property_hash)) }

      specify { expect(affiliate.css_property_hash(true)).to eq(Affiliate::THEMES[:default].merge(css_property_hash)) }
    end
  end

  describe "scope_ids_as_array" do
    context "when an affiliate has a non-null scope_ids attribute" do
      before do
        @affiliate = Affiliate.new(:scope_ids => 'Scope1,Scope2,Scope3')
      end

      it "should return the scopes as an array" do
        expect(@affiliate.scope_ids_as_array).to eq(['Scope1', 'Scope2', 'Scope3'])
      end
    end

    context "when the scope_ids have spaces near the commas" do
      before do
        @affiliate = Affiliate.new(:scope_ids => "Scope1, Scope2, Scope3")
      end

      it "should strip out whitespace" do
        expect(@affiliate.scope_ids_as_array).to eq(['Scope1', 'Scope2', 'Scope3'])
      end
    end

    context "when an affiliate has a nil scope_ids attribute" do
      before do
        @affiliate = Affiliate.new
      end

      it "should return an empty array" do
        expect(@affiliate.scope_ids_as_array).to eq([])
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
        expect(site_domains.size).to eq(2)
        expect(site_domains.collect(&:domain).sort).to eq(%w{blat.gov/somedir foo.gov})
      end
    end

    context "when input domains have blank/whitespace" do
      it "should delete blank/whitespace from domains" do
        site_domain_hash = ActiveSupport::OrderedHash[" do.gov ", nil, " bar.gov", nil, "blat.gov ", nil]
        affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains(true)
        expect(site_domains.size).to eq(3)
        expect(site_domains.collect(&:domain).sort).to eq(%w{bar.gov blat.gov do.gov})
      end
    end

    context "when input domains have dupes" do
      before do
        affiliate.add_site_domains("foo.gov" => nil)
      end

      it "should delete dupes from domains" do
        expect(affiliate.add_site_domains('foo.gov' => nil)).to be_empty

        site_domains = affiliate.site_domains(true)
        expect(site_domains.count).to eq(1)
        expect(site_domains.first.domain).to eq('foo.gov')
      end
    end

    context "when input domains don't look like domains" do
      it "should filter them out" do
        site_domain_hash = ActiveSupport::OrderedHash['foo.gov', nil, 'somepage.info', nil, 'whatisthis?', nil, 'bar.gov/somedir/', nil]
        affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains(true)
        expect(site_domains.count).to eq(3)
        expect(site_domains.collect(&:domain).sort).to eq(%w{bar.gov/somedir foo.gov somepage.info})
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
        expect(SiteDomain.where(:affiliate_id => affiliate.id).count).to eq(6)
      end

      it "should filter out existing domains" do
        added_site_domains = affiliate.add_site_domains({'foo.gov' => nil, 'bar.gov' => nil})

        expect(added_site_domains.count).to eq(2)
        site_domains = affiliate.site_domains(true)
        expect(site_domains.count).to eq(3)
        expect(site_domains[0].domain).to eq('agency.gov')
        expect(site_domains[1].domain).to eq('bar.gov')
        expect(site_domains[2].domain).to eq('foo.gov')
      end
    end
  end

  describe "#update_site_domain" do
    let(:affiliate) {  Affiliate.create!(valid_create_attributes) }
    let(:site_domain) { SiteDomain.find_by_affiliate_id_and_domain(affiliate.id, 'www.gsa.gov') }

    context "when existing domain is covered by new ones" do
      before do
        affiliate.add_site_domains({'www1.usa.gov' => nil, 'www2.usa.gov' => nil, 'www.gsa.gov' => nil})
        expect(SiteDomain.where(:affiliate_id => affiliate.id).count).to eq(3)
      end

      it "should filter out existing domains" do
        expect(affiliate.update_site_domain(site_domain, {:domain => 'usa.gov', :site_name => nil})).to be_truthy
        site_domains = affiliate.site_domains(true)
        expect(site_domains.count).to eq(1)
        expect(site_domains.first.domain).to eq('usa.gov')
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
      expect(Resque).to receive(:enqueue_with_priority).with(:low, AffiliateIndexedDocumentFetcher, @affiliate.id, @first.id, @second.id, 'not_ok')
      expect(Resque).to receive(:enqueue_with_priority).with(:low, AffiliateIndexedDocumentFetcher, @affiliate.id, @third.id, @third.id, 'not_ok')
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

      affiliate = Affiliate.create!(valid_attributes.merge(header: tainted_header))
      expect(affiliate.sanitized_header.strip).to eq(%q(<h1 id="my_header">header</h1>))
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

      affiliate = Affiliate.create!(valid_attributes.merge(footer: tainted_footer))
      expect(affiliate.sanitized_footer.strip).to eq(%q(<h1 id="my_footer">footer</h1>))
    end
  end

  describe "#unused_features" do
    before do
      @affiliate = affiliates(:power_affiliate)
      @affiliate.features.delete_all
    end

    it "should return the collection of unused features for the affiliate" do
      ufs = @affiliate.unused_features
      expect(ufs.size).to eq(2)
      @affiliate.features << features(:sayt)
      ufs = @affiliate.unused_features
      expect(ufs.size).to eq(1)
      expect(ufs.first).to eq(features(:disco))
    end
  end

  describe '#last_month_query_count' do
    let(:count_query) { double('CountQuery', body: 'any body') }

    before do
      allow(Date).to receive(:current).and_return(Date.new(2014, 4, 1))
    end

    it 'returns previous month filtered search count from human-logstash-* indexes' do
      affiliate = affiliates(:power_affiliate)
      expect(CountQuery).to receive(:new).with(affiliate.name).and_return count_query
      expect(RtuCount).to receive(:count).with("human-logstash-2014.03.*", 'search', count_query.body).and_return(88)
      expect(affiliate.last_month_query_count).to eq(88)
    end
  end

  describe '#user_emails' do
    it 'returns comma delimited user emails' do
      affiliate = affiliates(:non_existent_affiliate)
      expect(affiliate.user_emails).to eq('Another Manager <another_affiliate_manager@fixtures.org>,Pending Email Verification Affiliate Manager <affiliate_manager_with_pending_email_verification_status@fixtures.org>')
    end
  end

  describe '#mobile_logo_url' do
    it 'returns mobile logo url' do
      mobile_logo_url = 'http://link.to/mobile_logo.png'.freeze
      mobile_logo = double('mobile logo')
      affiliate = affiliates(:power_affiliate)
      expect(affiliate).to receive(:mobile_logo_file_name).and_return('mobile_logo.png')
      expect(affiliate).to receive(:mobile_logo).and_return(mobile_logo)
      expect(mobile_logo).to receive(:url).and_return(mobile_logo_url)

      expect(affiliate.mobile_logo_url).to eq(mobile_logo_url)
    end
  end

  describe '#header_image_url' do
    it 'returns header image url' do
      header_image_url = 'http://link.to/header_image.png'.freeze
      header_image = double('header image')
      affiliate = affiliates(:power_affiliate)
      expect(affiliate).to receive(:header_image_file_name).and_return('header_image.png')
      expect(affiliate).to receive(:header_image).and_return(header_image)
      expect(header_image).to receive(:url).and_return(header_image_url)

      expect(affiliate.header_image_url).to eq(header_image_url)
    end
  end

  describe '#assign_sitelink_generator_names!' do
    it 'assigns sitelink generator names' do
      sitelink_generator_names = %w(SitelinkGenerator::FakeGenerator).freeze
      expect(SitelinkGeneratorUtils).to receive(:matching_generator_names).
        with(%w(sec.gov)).
        and_return(sitelink_generator_names)

      affiliate = affiliates(:power_affiliate)
      affiliate.site_domains.create!(domain: 'sec.gov')
      affiliate.assign_sitelink_generator_names!
      expect(affiliate.sitelink_generator_names).to eq(sitelink_generator_names)
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
        expect(affiliate.should_show_job_organization_name?).to be true
      end
    end

    context 'when agency has no org codes' do
      before do
        agency = Agency.create!(name: "National Park Service", abbreviation: "NPS")
        affiliate.agency = agency
      end

      it 'should return true' do
        expect(affiliate.should_show_job_organization_name?).to be true
      end
    end

    context 'when agency org codes are all department level' do
      before do
        agency = Agency.create!(name: "National Park Service", abbreviation: "NPS")
        AgencyOrganizationCode.create!(organization_code: "GS", agency: agency)
        affiliate.agency = agency
      end

      it 'should return true' do
        expect(affiliate.should_show_job_organization_name?).to be true
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
        expect(affiliate.should_show_job_organization_name?).to be false
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
      expect(affiliate.rss_feeds.last.name).to eq("Vídeos")
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
                        page_background_image_content_type
                        page_background_image_file_name
                        page_background_image_file_size
                        page_background_image_updated_at)

    it 'sets @css_property_hash instance variable' do
      expect(subject.instance_variable_get(:@css_property_hash)).to include(:title_link_color, :visited_title_link_color)
    end
  end

  describe 'has_many :affiliate_templates' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:template_rounded) { affiliate_templates(:usagov_rounded_header_link)}

    describe "#load_template_schema" do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it "loads the templates Schema if no schema is stored in DB" do
        expect(affiliate.load_template_schema).to eq(Template.default.schema)
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
        allow(Template).to receive_message_chain(:default, :schema).and_return({"schema" => {"default" => "default" }})
        affiliate.save_template_schema({ "schema" => {"test_schema" => "test"}})
        expect(affiliate.load_template_schema).to eq(Hashie::Mash.new({"schema"=>{"default"=>"default", "test_schema"=>"test"}}))
      end

      it "loads the schema if not blank, merges new values and saves the schema" do
        affiliate.template_schema = {"schema" => {"default" => "default" }}.to_json
        affiliate.save
        affiliate.reload

        affiliate.save_template_schema({ "schema" => {"test_schema" => "test"}})
        expected_schema = {"schema"=>{"default"=>"default", "test_schema"=>"test"}}
        expect(affiliate.load_template_schema).to eq(expected_schema)
      end

    end

    describe "#reset_template_schema" do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it "resets the schema" do
        affiliate.update_attribute(:template_schema, {"test" => "test"}.to_json)
        allow(Template).to receive_message_chain(:default, :schema).and_return({"css" => {"default" => "default" }})
        expect(affiliate.reset_template_schema).to eq(Hashie::Mash.new({"css"=>{"default"=>"default"}}))
      end
    end

    describe "#port_classic_theme" do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it "merges existing colors into template_schema" do
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
        expect(affiliate.send(image).url).to match /https:\/\/.*\.s3\.amazonaws\.com\/test\/site\/#{affiliate.id}\/#{image}\/\d+\/original\/corgi.jpg/

      end
    end
  end

  describe '#template' do
    context 'when no template has been assigned' do
      let(:affiliate) { Affiliate.new }
      it 'returns the default template' do
        expect(affiliate.template.name).to eq 'Classic'
      end
    end
  end

  describe '#update_templates' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:classic) { Template.find_by_name('Classic') }
    let(:irs) { Template.find_by_name('IRS') }
    let(:rounded) { Template.find_by_name('Rounded Header Links') }
    let(:square) { Template.find_by_name('Square Header Links') }

    before do
      affiliate.affiliate_templates.create!(template_id: classic.id)
      affiliate.affiliate_templates.create!(template_id: irs.id)
      affiliate.update_attribute(:template_id, classic.id)
      affiliate.update_templates(rounded.id, [rounded.id, irs.id])
    end

    it 'sets the active template' do
      expect(affiliate.template.name).to eq 'Rounded Header Links'
    end

    it 'makes selected templates available' do
      expect(affiliate.available_templates.pluck(:name)).
        to match_array(['Rounded Header Links','IRS'])
    end

    it 'makes unselected templates unavailable' do
      expect(affiliate.available_templates.pluck(:name)).
        not_to include('Square Header Links','Classic')
    end
  end

  describe '#sc_search_engine' do
    subject { Affiliate.new(valid_create_attributes.merge(search_engine: search_engine)) }

    {
      'Bing' => 'Bing',
      'BingV6' => 'Bing',
      'BingV7' => 'Bing',
      'Google' => 'Google',
    }.each do |configured_search_engine, sc_reported_search_engine|
      context "when an affiliate's search_engine is '#{configured_search_engine}'" do
        let(:search_engine) { configured_search_engine }

        it "reports sc_search_engine as '#{sc_reported_search_engine}'" do
          expect(subject.sc_search_engine).to eql(sc_reported_search_engine)
        end
      end
    end
  end

  describe '#status' do
    subject(:status) { affiliate.status }

    context 'when the affiliate is active' do
      before { allow(affiliate).to receive(:active?).and_return(true) }

      it { is_expected.to eq('Active') }
    end

    context 'when the affiliate is inactive' do
      before { allow(affiliate).to receive(:active?).and_return(false) }

      it { is_expected.to eq('Inactive') }
    end
  end

  describe '#excluded_urls_set' do
    before do
      affiliate.save!
      affiliate.excluded_urls.create!(url: 'http://excluded.com')
      affiliate.excluded_urls.create!(url: 'https://excluded.com')
    end

    it 'returns unique excluded urls without protocol' do
      expect(affiliate.excluded_urls_set).to eq ['excluded.com']
    end
  end
end
