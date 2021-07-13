# frozen_string_literal: true

describe Affiliate do
  let(:valid_create_attributes) do
    { display_name: 'My Awesome Site',
      name: 'myawesomesite',
      website: 'http://www.someaffiliate.gov',
      locale: 'es' }.freeze
   end
   let(:valid_attributes) { valid_create_attributes.merge(name: 'someaffiliate.gov').freeze }
   let(:affiliate) { described_class.new(valid_create_attributes) }

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
      it { is_expected.to have_attached_file :mobile_logo }
      it { is_expected.to have_attached_file :header_tagline_logo }
    end
  end

  describe 'Creating new instance of Affiliate' do
    it { is_expected.to validate_presence_of :display_name }
    Language.pluck(:code).each do |locale|
      it { is_expected.to allow_value(locale).for(:locale) }
    end
    it { is_expected.to validate_presence_of :locale }
    it { is_expected.to validate_uniqueness_of(:api_access_key).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(33) }
    ['<IMG SRC=', "259771935505'", 'spacey name'].each do |value|
      it { is_expected.not_to allow_value(value).for(:name) }
    end
    %w{data.gov ct-new some_aff 123 NewAff}.each do |value|
      it { is_expected.to allow_value(value).for(:name) }
    end
    it { is_expected.to validate_attachment_size(:mobile_logo).in(1..64.kilobytes) }
    it { is_expected.to validate_attachment_size(:header_tagline_logo).in(1..16.kilobytes) }

    %i[header_tagline_logo mobile_logo].each do |image|
          it { is_expected.to validate_attachment_content_type(image).
               allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).
               rejecting(nil, %w{ text/plain text/xml application/pdf }) }
    end

    it { is_expected.to validate_inclusion_of(:search_engine).in_array(%w( Google BingV6 BingV7 SearchGov )) }

    it { is_expected.to have_many :boosted_contents }
    it { is_expected.to have_many(:connections).inverse_of(:affiliate) }
    it { is_expected.to have_many(:connected_connections).inverse_of(:connected_affiliate) }

    it { is_expected.to have_many :sayt_suggestions }
    it { is_expected.to have_many :twitter_profiles }

    it { is_expected.to have_many(:routed_query_keywords).through :routed_queries }
    it { is_expected.to have_many(:rss_feed_urls).through(:rss_feeds) }
    it { is_expected.to have_many(:users).through :memberships }

    it { is_expected.to have_many(:affiliate_feature_addition).dependent(:destroy) }
    it { is_expected.to have_many(:affiliate_twitter_settings).dependent(:destroy) }
    it { is_expected.to have_many(:excluded_domains).dependent(:destroy).inverse_of(:affiliate) }
    it { is_expected.to have_many(:featured_collections).dependent(:destroy) }
    it { is_expected.to have_many(:features).dependent(:destroy) }
    it { is_expected.to have_many(:document_collections).inverse_of(:affiliate) }

    it do
      is_expected.to have_many(:flickr_profiles).dependent(:destroy).
        inverse_of(:affiliate)
    end

    it { is_expected.to have_many(:memberships).dependent(:destroy) }

    it do
      is_expected.to have_many(:navigations).dependent(:destroy).inverse_of(:affiliate)
    end

    it { is_expected.to have_many(:routed_queries).dependent(:destroy) }
    it { is_expected.to have_many(:rss_feeds).dependent(:destroy).inverse_of(:owner) }
    it { is_expected.to have_many(:affiliate_templates).dependent(:destroy) }

    it do
      is_expected.to have_many(:available_templates).through(:affiliate_templates).source(:template)
    end

    it do
      is_expected.to have_many(:site_domains).dependent(:destroy).
        inverse_of(:affiliate)
    end

    it 'has many default users' do
      is_expected.to have_many(:default_users).dependent(:nullify).
        with_foreign_key(:default_affiliate_id).
        class_name('User').inverse_of(:default_affiliate)
    end

    it { is_expected.to have_many(:watchers).inverse_of(:affiliate) }

    it do
      is_expected.to have_many(:tag_filters).dependent(:destroy).inverse_of(:affiliate)
    end

    it { is_expected.to have_and_belong_to_many :instagram_profiles }
    it { is_expected.to have_and_belong_to_many :youtube_profiles }
    it { is_expected.to belong_to :agency }
    it { is_expected.to belong_to(:language).inverse_of(:affiliates) }
    it { is_expected.to belong_to :template }
    it { is_expected.to validate_attachment_content_type(:mobile_logo).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }

    it 'should create a new instance given valid attributes' do
      described_class.create!(valid_create_attributes)
    end

    it "should downcase the name if it's uppercase" do
      affiliate = described_class.new(valid_create_attributes)
      affiliate.name = 'AffiliateSite'
      affiliate.save!
      expect(affiliate.name).to eq('affiliatesite')
    end

    describe 'on create' do
      it 'should update css_properties with json string from css property hash' do
        css_property_hash = {'title_link_color' => '#33ff33', 'visited_title_link_color' => '#0000ff'}
        affiliate = described_class.create!(valid_create_attributes.merge(css_property_hash: css_property_hash))
        expect(JSON.parse(affiliate.css_properties, symbolize_names: true)[:title_link_color]).to eq('#33ff33')
        expect(JSON.parse(affiliate.css_properties, symbolize_names: true)[:visited_title_link_color]).to eq('#0000ff')
      end

      it 'should normalize site domains' do
        affiliate = described_class.create!(valid_create_attributes.merge(
                                          site_domains_attributes: { '0' => { domain: 'www1.usa.gov' },
                                                                     '1' => { domain: 'www2.usa.gov' },
                                                                     '2' => { domain: 'usa.gov' } }))
        expect(affiliate.site_domains.reload.count).to eq(1)
        expect(affiliate.site_domains.first.domain).to eq('usa.gov')

        affiliate = described_class.create!(
            valid_create_attributes.merge(
                name: 'anothersite',
                site_domains_attributes: { '0' => { domain: 'sec.gov' },
                                           '1' => { domain: 'www.sec.gov.staging.net' } }))
        expect(affiliate.site_domains.reload.count).to eq(2)
        expect(affiliate.site_domains.pluck(:domain).sort).to eq(%w(sec.gov www.sec.gov.staging.net))
      end

      it 'should default the govbox fields to OFF' do
        affiliate = described_class.create!(valid_create_attributes)
        expect(affiliate.is_medline_govbox_enabled).to eq(false)
      end

      it 'should have SAYT enabled by default' do
        expect(described_class.create!(valid_create_attributes).is_sayt_enabled).to be true
      end

      it 'should generate a database-level error when attempting to add an ' \
         'affiliate with the same name as an existing affiliate, but with ' \
         'different case; instead it should return false' do
        affiliate = described_class.new(valid_attributes)
        affiliate.name = valid_attributes[:name]
        affiliate.save!
        duplicate_affiliate = described_class.new(valid_attributes)
        duplicate_affiliate.name = valid_attributes[:name].upcase
        expect(duplicate_affiliate.save).to be false
      end

      it 'should populate default search label for English site' do
        affiliate = described_class.create!(valid_attributes.merge(locale: 'en'))
        expect(affiliate.default_search_label).to eq('Everything')
      end

      it 'should populate default search labels for Spanish site' do
        affiliate = described_class.create!(valid_attributes.merge(locale: 'es'))
        expect(affiliate.default_search_label).to eq('Todo')
      end

      it 'should set look_and_feel_css' do
        affiliate = described_class.create! valid_attributes
        expect(affiliate.mobile_look_and_feel_css).to include('font-family:"Maven Pro"')
        expect(affiliate.mobile_look_and_feel_css).to include('a:visited{color:purple}')
      end

      it 'assigns api_access_key' do
        affiliate = described_class.create! valid_attributes
        expect(affiliate.api_access_key).to be_present
      end
    end
  end

  describe 'on save' do
    let(:affiliate) { described_class.create!(valid_create_attributes) }

    it 'should not override default theme attributes' do
      affiliate.theme = 'default'
      affiliate.css_property_hash = {page_background_color: '#FFFFFF'}
      affiliate.save!
      expect(described_class.find(affiliate.id).css_property_hash[:page_background_color]).to eq(Affiliate::THEMES[:default][:page_background_color])
    end

    it 'should save favicon URL with http:// prefix when it does not start with http(s)://' do
      url = 'cdn.agency.gov/favicon.ico'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        affiliate.update_attributes!(favicon_url: "#{prefix}#{url}")
        expect(affiliate.favicon_url).to eq("http://#{prefix}#{url}")
      end
    end

    it 'should save favicon URL as is when it starts with http(s)://' do
      url = 'cdn.agency.gov/favicon.ico'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        affiliate.update_attributes(favicon_url: "#{prefix}#{url}")
        expect(affiliate.favicon_url).to eq("#{prefix}#{url}")
      end
    end

    it 'should save external CSS URL with http:// prefix when it does not start with http(s)://' do
      url = 'cdn.agency.gov/custom.css'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        affiliate.update_attributes!(external_css_url: "#{prefix}#{url}")
        expect(affiliate.external_css_url).to eq("http://#{prefix}#{url}")
      end
    end

    it 'should save external CSS URL as is when it starts with http(s)://' do
      url = 'cdn.agency.gov/custom.css'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        affiliate.update_attributes!(external_css_url: "#{prefix}#{url}")
        expect(affiliate.external_css_url).to eq("#{prefix}#{url}")
      end
    end

    it 'should prefix website with http://' do
      affiliate.update_attributes!(website: 'usa.gov')
      expect(affiliate.website).to eq('http://usa.gov')
    end

    it 'should set css properties' do
      affiliate.css_property_hash = { font_family: 'Verdana, sans-serif' }
      affiliate.save!
      expect(described_class.find(affiliate.id).css_property_hash[:font_family]).to eq('Verdana, sans-serif')
    end

    it 'should populate search labels for English site' do
      english_affiliate = described_class.create!(valid_attributes.merge(locale: 'en'))
      english_affiliate.default_search_label = ''
      english_affiliate.save!
      expect(english_affiliate.default_search_label).to eq('Everything')
    end

    it 'should populate search labels for Spanish site' do
      spanish_affiliate = described_class.create!(valid_attributes.merge(locale: 'es'))
      spanish_affiliate.default_search_label = ''
      spanish_affiliate.save!
      expect(spanish_affiliate.default_search_label).to eq('Todo')
    end

    it 'should squish string columns' do
      affiliate = described_class.create!(valid_create_attributes)
      unsquished_attributes = {
        ga_web_property_id: ' GA Web Property  ID  ',
        header_tagline_font_size: ' 12px ',
        logo_alt_text: ' this  is   my   logo ',
        navigation_dropdown_label: '  My   Location  ',
        related_sites_dropdown_label: '  More   related   sites  '
      }.freeze

      affiliate.update_attributes!(unsquished_attributes)

      affiliate = described_class.find affiliate.id
      expect(affiliate.ga_web_property_id).to eq('GA Web Property ID')
      expect(affiliate.header_tagline_font_size).to eq('12px')
      expect(affiliate.logo_alt_text).to eq('this is my logo')
      expect(affiliate.navigation_dropdown_label).to eq('My Location')
      expect(affiliate.related_sites_dropdown_label).to eq('More related sites')
    end


    it 'should set default RSS govbox label if the value is blank' do
      en_affiliate = described_class.create!(valid_create_attributes.merge(locale: 'en'))
      expect(en_affiliate.rss_govbox_label).to eq('News')
      en_affiliate.update_attributes!(rss_govbox_label: '')
      expect(en_affiliate.rss_govbox_label).to eq('News')

      es_affiliate = described_class.create!(valid_create_attributes.merge(locale: 'es', name: 'es-site'))
      expect(es_affiliate.rss_govbox_label).to eq('Noticias')
      es_affiliate.update_attributes!({ rss_govbox_label: '' })
      expect(es_affiliate.rss_govbox_label).to eq('Noticias')
    end

    it 'should squish related sites dropdown label' do
      affiliate = described_class.create!(valid_create_attributes.merge(locale: 'en', name: 'en-site'))
      affiliate.related_sites_dropdown_label = ' Search  Only'
      affiliate.save!
      expect(affiliate.related_sites_dropdown_label).to eq('Search Only')
    end

    it 'should set blank related sites dropdown label to nil' do
      affiliate = described_class.create!(valid_create_attributes.merge(locale: 'en', name: 'en-site'))
      affiliate.related_sites_dropdown_label = ' '
      affiliate.save!
      expect(affiliate.related_sites_dropdown_label).to be_nil
    end
  end

  describe 'on destroy' do
    let(:affiliate) { described_class.create!(display_name: 'connecting affiliate', name: 'anothersite') }
    let(:connected_affiliate) { described_class.create!(display_name: 'connected affiliate', name: 'connectedsite') }

    it 'should destroy connection' do
      affiliate.connections.create!(connected_affiliate: connected_affiliate, label: 'search connected affiliate')
      expect(described_class.find(affiliate.id).connections.count).to eq(1)
      connected_affiliate.destroy
      expect(described_class.find(affiliate.id).connections.count).to eq(0)
    end
  end

  describe 'validations' do
    it 'should be valid when FONT_FAMILIES includes font_family in css property hash' do
      FontFamily::ALL.each do |font_family|
        expect(described_class.new(valid_create_attributes.merge(css_property_hash: {'font_family' => font_family}))).to be_valid
      end
    end

    it 'should not be valid when FONT_FAMILIES does not include font_family in css property hash' do
      expect(described_class.new(valid_create_attributes.merge(css_property_hash: {'font_family' => 'Comic Sans MS'}))).not_to be_valid
    end

    it 'should be valid when color property in css property hash consists of a # character followed by 3 or 6 hexadecimal digits ' do
      %w{ #333 #FFF #fff #12F #666666 #666FFF #FFFfff #ffffff }.each do |valid_color|
        css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({'left_tab_text_color' => "#{valid_color}",
                                                                          'title_link_color' => "#{valid_color}",
                                                                          'visited_title_link_color' => "#{valid_color}",
                                                                          'description_text_color' => "#{valid_color}",
                                                                          'url_link_color' => "#{valid_color}"})
        expect(described_class.new(valid_create_attributes.merge(css_property_hash: css_property_hash))).to be_valid
      end
    end

    it 'should be invalid when color property in css property hash does not consist of a # character followed by 3 or 6 hexadecimal digits ' do
      %w{ 333 invalid #err #1 #22 #4444 #55555 ffffff 1 22 4444 55555 666666 }.each do |invalid_color|
        css_property_hash = ActiveSupport::HashWithIndifferentAccess.new({'left_tab_text_color' => "#{invalid_color}",
                                                                          'title_link_color' => "#{invalid_color}",
                                                                          'visited_title_link_color' => "#{invalid_color}",
                                                                          'description_text_color' => "#{invalid_color}",
                                                                          'url_link_color' => "#{invalid_color}"})
        affiliate = described_class.new(valid_create_attributes.merge(css_property_hash: css_property_hash))
        expect(affiliate).not_to be_valid
        expect(affiliate.errors[:base]).to include('Title link color should consist of a # character followed by 3 or 6 hexadecimal digits')
        expect(affiliate.errors[:base]).to include('Visited title link color should consist of a # character followed by 3 or 6 hexadecimal digits')
        expect(affiliate.errors[:base]).to include('Description text color should consist of a # character followed by 3 or 6 hexadecimal digits')
        expect(affiliate.errors[:base]).to include('Url link color should consist of a # character followed by 3 or 6 hexadecimal digits')
      end
    end

    it 'validates logo alignment' do
      expect(described_class.new(valid_create_attributes.merge(
                        css_property_hash: { 'logo_alignment' => 'invalid' }))).not_to be_valid
    end

    it 'validates locale is valid' do
      affiliate = described_class.new(valid_create_attributes.merge(locale: 'invalid_locale'))
      expect(affiliate.save).to be false
      expect(affiliate.errors[:base]).to include('Locale must be valid')
    end

    describe 'header tagline validation' do
      let(:affiliate) do
        described_class.new(valid_create_attributes.
          merge(header_tagline_url: header_tagline_url))
      end
      let(:header_tagline_url) { 'http://www.google.com' }

      context 'when the URL is valid' do
        it 'is valid' do
          expect(affiliate).to be_valid
        end
      end

      context 'when the URL is invalid' do
        let(:header_tagline_url) { 'foo' }

        it 'is invalid' do
          expect(affiliate).not_to be_valid
          expect(affiliate.errors[:header_tagline_url]).to include 'is not a valid URL'
        end
      end

      context 'when the URL is includes javascript' do
        let(:header_tagline_url) { 'javascript:alert(document.domain)' }

        it 'is invalid' do
          expect(affiliate).not_to be_valid
          expect(affiliate.errors[:header_tagline_url]).to include 'is not a valid URL'
        end
      end
    end

    describe 'bing v5 key stripping' do
      subject { described_class.new(valid_create_attributes.merge(bing_v5_key: bing_v5_key)) }
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
        ' da076306990394a250f5f2ecd8cfc323  ' => 'da076306990394a250f5f2ecd8cfc323'
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
      subject { described_class.new(valid_create_attributes.merge(bing_v5_key: bing_v5_key)) }

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

    it 'allows valid external tracking code' do
      expect { described_class.create!({ display_name: 'a site',
                                   external_tracking_code: '<script>var a;</script>',
                                   name: 'external-tracking-site'}) }.to_not raise_error
    end

    # malformed tags are rejected, but missing tags are not, i.e. "<h1>foo"
    # https://cm-jira.usa.gov/browse/SRCH-2274
    it 'does not allow malformed external tracking code' do
      affiliate = described_class.new(
        valid_attributes.merge(external_tracking_code: '<script>var a;</script')
      )
      expect(affiliate).not_to be_valid
      expect(affiliate.errors.full_messages).to include(
        "External tracking code is invalid: 1:35: ERROR: End tag : expected '>'."
      )
    end

    it 'allows valid external tracking code' do
      expect { described_class.create!({ display_name: 'a site',
                                   footer_fragment: '<script>var a;</script>',
                                   name: 'footer-fragment-site'}) }.to_not raise_error
    end

    # malformed tags are rejected, but missing tags are not, i.e. "<h1>foo"
    # https://cm-jira.usa.gov/browse/SRCH-2274
    it 'does not allow a malformed footer_fragment' do
      affiliate = described_class.new(
        valid_attributes.merge(footer_fragment: '<script>var a;</script')
      )
      expect(affiliate).not_to be_valid
      expect(affiliate.errors.full_messages).to include(
        "Footer fragment is invalid: 1:35: ERROR: End tag : expected '>'."
      )
    end
  end

  describe '.human_attribute_name' do
    specify { expect(described_class.human_attribute_name('display_name')).to eq('Display name') }
    specify { expect(described_class.human_attribute_name('name')).to eq('Site Handle (visible to searchers in the URL)') }
  end

  describe '#ordered' do
    it "should include a scope called 'ordered'" do
      expect(described_class.ordered).not_to be_nil
    end
  end

  describe '#has_multiple_domains?' do
    let(:affiliate) { described_class.create!(valid_create_attributes) }

    context 'when Affiliate has more than 1 domain' do
      before do
        affiliate.add_site_domains('foo.gov' => nil, 'bar.gov' => nil)
      end

      specify { expect(affiliate).to have_multiple_domains }
    end

    context 'when Affiliate has no domain' do
      specify { expect(affiliate).not_to have_multiple_domains }
    end

    context 'when Affiliate has 1 domain' do
      before do
        affiliate.add_site_domains('foo.gov' => nil)
      end
      specify { expect(affiliate).not_to have_multiple_domains }
    end
  end

  describe '#recent_user_activity' do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate_manager) { users(:another_affiliate_manager) }
    let(:affiliate_manager_with_one_site) { users(:affiliate_manager_with_one_site) }
    let(:recent_time) { Time.now.utc }

    before do
      @au = affiliate.users.first
      @au.last_request_at = recent_time
      @au.save!

      another_affiliate_manager.last_request_at = recent_time - 1.hour
      another_affiliate_manager.save!

      affiliate_manager_with_one_site.last_request_at = nil
      affiliate_manager_with_one_site.save!

      affiliate.users << another_affiliate_manager
      affiliate.users << affiliate_manager_with_one_site
    end

    it 'should show the max last_request_at date for the site users' do
      expect(affiliate.recent_user_activity.utc.to_s).to eq(recent_time.to_s)
    end
  end

  describe '#has_no_social_image_feeds?' do
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
        feed = affiliate.rss_feeds.build(name: 'mrss', show_only_media_content: true)
        feed.rss_feed_urls.build(url: 'http://www.defense.gov/news/mrss_leadphotos.xml', last_crawl_status: 'OK',
                                 oasis_mrss_name: nil, rss_feed_owner_type: 'Affiliate')
        allow(feed.rss_feed_urls.first).to receive(:url_must_point_to_a_feed) { true }
        feed.save!
      end
      specify { expect(affiliate).to have_no_social_image_feeds }
    end
  end

  describe '#css_property_hash' do
    context 'when theme is custom' do
      let(:css_property_hash) { {title_link_color: '#33ff33', visited_title_link_color: '#0000ff'}.reverse_merge(Affiliate::DEFAULT_CSS_PROPERTIES) }
      let(:affiliate) { described_class.create!(valid_create_attributes.merge(theme: 'custom', css_property_hash: css_property_hash)) }

      specify { expect(affiliate.css_property_hash(true)).to eq(css_property_hash) }
    end

    context 'when theme is default' do
      let(:css_property_hash) { { font_family: FontFamily::ALL.last } }
      let(:affiliate) { described_class.create!(
        valid_create_attributes.merge(theme: 'default',
                                       css_property_hash: css_property_hash)) }

      specify { expect(affiliate.css_property_hash(true)).to eq(Affiliate::THEMES[:default].merge(css_property_hash)) }
    end
  end

  describe 'scope_ids_as_array' do
    context 'when an affiliate has a non-null scope_ids attribute' do
      before do
        @affiliate = described_class.new(scope_ids: 'Scope1,Scope2,Scope3')
      end

      it 'should return the scopes as an array' do
        expect(@affiliate.scope_ids_as_array).to eq(['Scope1', 'Scope2', 'Scope3'])
      end
    end

    context 'when the scope_ids have spaces near the commas' do
      before do
        @affiliate = described_class.new(scope_ids: 'Scope1, Scope2, Scope3')
      end

      it 'should strip out whitespace' do
        expect(@affiliate.scope_ids_as_array).to eq(['Scope1', 'Scope2', 'Scope3'])
      end
    end

    context 'when an affiliate has a nil scope_ids attribute' do
      before do
        @affiliate = described_class.new
      end

      it 'should return an empty array' do
        expect(@affiliate.scope_ids_as_array).to eq([])
      end
    end
  end

  describe '#add_site_domains' do
    let(:affiliate) { described_class.create!(valid_create_attributes) }

    context 'when input domains have leading http(s) protocols' do
      it 'should delete leading http(s) protocols from domains' do
        site_domain_hash = ActiveSupport::OrderedHash['http://foo.gov', nil, 'bar.gov/somepage.html', nil, 'https://blat.gov/somedir', nil]
        affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains.reload
        expect(site_domains.size).to eq(2)
        expect(site_domains.collect(&:domain).sort).to eq(%w{blat.gov/somedir foo.gov})
      end
    end

    context 'when input domains have blank/whitespace' do
      it 'should delete blank/whitespace from domains' do
        site_domain_hash = ActiveSupport::OrderedHash[' do.gov ', nil, ' bar.gov', nil, 'blat.gov ', nil]
        affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains.reload
        expect(site_domains.size).to eq(3)
        expect(site_domains.collect(&:domain).sort).to eq(%w{bar.gov blat.gov do.gov})
      end
    end

    context 'when input domains have dupes' do
      before do
        affiliate.add_site_domains('foo.gov' => nil)
      end

      it 'should delete dupes from domains' do
        expect(affiliate.add_site_domains('foo.gov' => nil)).to be_empty

        site_domains = affiliate.site_domains.reload
        expect(site_domains.count).to eq(1)
        expect(site_domains.first.domain).to eq('foo.gov')
      end
    end

    context "when input domains don't look like domains" do
      it 'should filter them out' do
        site_domain_hash = ActiveSupport::OrderedHash['foo.gov', nil, 'somepage.info', nil, 'whatisthis?', nil, 'bar.gov/somedir/', nil]
        affiliate.add_site_domains(site_domain_hash)

        site_domains = affiliate.site_domains.reload
        expect(site_domains.count).to eq(3)
        expect(site_domains.collect(&:domain).sort).to eq(%w{bar.gov/somedir foo.gov somepage.info})
      end
    end

    context 'when one input domain is covered by another' do
      it 'should filter it out' do
        site_domain_hash = ActiveSupport::OrderedHash['blat.gov', nil, 'blat.gov/s.html', nil, 'bar.gov/somedir/', nil, 'bar.gov', nil, 'www.bar.gov', nil, 'xxbar.gov', nil]
        added_site_domains = affiliate.add_site_domains(site_domain_hash)

        site_domain_names = affiliate.site_domains.reload.pluck(:domain)
        expect(added_site_domains.map(&:domain)).to eq(site_domain_names)
        expect(site_domain_names).to eq(%w(bar.gov blat.gov xxbar.gov))
      end
    end

    context 'when existing domains are covered by new ones' do
      let(:domains) { %w( a.foo.gov b.foo.gov y.bar.gov z.bar.gov c.foo.gov agency.gov ) }

      before do
        site_domain_hash = Hash[domains.collect { |domain| [domain, nil] }]
        affiliate.add_site_domains(site_domain_hash)
        expect(SiteDomain.where(affiliate_id: affiliate.id).count).to eq(6)
      end

      it 'should filter out existing domains' do
        added_site_domains = affiliate.add_site_domains({'foo.gov' => nil, 'bar.gov' => nil})

        expect(added_site_domains.count).to eq(2)
        site_domains = affiliate.site_domains.reload
        expect(site_domains.count).to eq(3)
        expect(site_domains[0].domain).to eq('agency.gov')
        expect(site_domains[1].domain).to eq('bar.gov')
        expect(site_domains[2].domain).to eq('foo.gov')
      end
    end
  end

  describe '#update_site_domain' do
    let(:affiliate) {  described_class.create!(valid_create_attributes) }
    let(:site_domain) { SiteDomain.find_by_affiliate_id_and_domain(affiliate.id, 'www.gsa.gov') }

    context 'when existing domain is covered by new ones' do
      before do
        affiliate.add_site_domains({'www1.usa.gov' => nil, 'www2.usa.gov' => nil, 'www.gsa.gov' => nil})
        expect(SiteDomain.where(affiliate_id: affiliate.id).count).to eq(3)
      end

      it 'should filter out existing domains' do
        expect(affiliate.update_site_domain(site_domain, {domain: 'usa.gov', site_name: nil})).to be_truthy
        site_domains = affiliate.site_domains.reload
        expect(site_domains.count).to eq(1)
        expect(site_domains.first.domain).to eq('usa.gov')
      end
    end
  end

  describe '#refresh_indexed_documents(scope)' do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @affiliate.fetch_concurrency = 2
      @first = @affiliate.indexed_documents.build(title: 'Document Title 1', description: 'This is a Document.', url: 'http://nps.gov/')
      @second = @affiliate.indexed_documents.build(title: 'Document Title 2', description: 'This is a Document 2.', url: 'http://nps.gov/foo')
      @third = @affiliate.indexed_documents.build(title: 'Document Title 3', description: 'This is a Document 3.', url: 'http://nps.gov/bar')
      @ok = @affiliate.indexed_documents.build(title: 'PDF Title',
                                               description: 'This is a PDF document.',
                                               url: 'http://nps.gov/pdf.pdf',
                                               last_crawl_status: IndexedDocument::OK_STATUS,
                                               last_crawled_at: Time.now,
                                               body: 'this is the doc body')
      @affiliate.save!
    end

    it 'should enqueue just the scoped docs in batches' do
      expect(Resque).to receive(:enqueue_with_priority).with(:low, AffiliateIndexedDocumentFetcher, @affiliate.id, @first.id, @second.id, 'not_ok')
      expect(Resque).to receive(:enqueue_with_priority).with(:low, AffiliateIndexedDocumentFetcher, @affiliate.id, @third.id, @third.id, 'not_ok')
      @affiliate.refresh_indexed_documents('not_ok')
    end
  end

  describe '#unused_features' do
    before do
      @affiliate = affiliates(:power_affiliate)
      @affiliate.features.delete_all
    end

    it 'should return the collection of unused features for the affiliate' do
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
      expect(CountQuery).to receive(:new).
        with(affiliate.name, 'search').
        and_return count_query
      expect(RtuCount).to receive(:count).
        with('human-logstash-2014.03.*', count_query.body).
        and_return(88)
      expect(affiliate.last_month_query_count).to eq(88)
    end
  end

  describe '#user_emails' do
    it 'returns comma delimited user emails' do
      affiliate = affiliates(:non_existent_affiliate)
      expect(affiliate.user_emails).
        to eq('Another Manager Smith <another_affiliate_manager@fixtures.org>,' \
              'Requires Manual Approval Affiliate Manager Smith '\
              '<affiliate_manager_requires_manual_approval@fixtures.org>')
    end
  end

  describe '#mobile_logo_url' do
    it 'returns mobile logo url' do
      mobile_logo_url = 'http://link.to/mobile_logo.png'
      mobile_logo = double('mobile logo')
      affiliate = affiliates(:power_affiliate)
      expect(affiliate).to receive(:mobile_logo_file_name).and_return('mobile_logo.png')
      expect(affiliate).to receive(:mobile_logo).and_return(mobile_logo)
      expect(mobile_logo).to receive(:url).and_return(mobile_logo_url)

      expect(affiliate.mobile_logo_url).to eq(mobile_logo_url)
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

  describe '#should_show_job_organization_name?' do
    let(:affiliate) { affiliates(:basic_affiliate) }

    context 'when agency is blank' do
      it 'should return true' do
        expect(affiliate.should_show_job_organization_name?).to be true
      end
    end

    context 'when agency has no org codes' do
      before do
        agency = Agency.create!(name: 'National Park Service', abbreviation: 'NPS')
        affiliate.agency = agency
      end

      it 'should return true' do
        expect(affiliate.should_show_job_organization_name?).to be true
      end
    end

    context 'when agency org codes are all department level' do
      before do
        agency = Agency.create!(name: 'National Park Service', abbreviation: 'NPS')
        AgencyOrganizationCode.create!(organization_code: 'GS', agency: agency)
        affiliate.agency = agency
      end

      it 'should return true' do
        expect(affiliate.should_show_job_organization_name?).to be true
      end
    end

    context 'when only some agency org codes are department level' do
      before do
        agency = Agency.create!(name: 'National Park Service', abbreviation: 'NPS')
        AgencyOrganizationCode.create!(organization_code: 'GS', agency: agency)
        AgencyOrganizationCode.create!(organization_code: 'AF', agency: agency)
        AgencyOrganizationCode.create!(organization_code: 'USMI', agency: agency)
        affiliate.agency = agency
      end

      it 'should return false' do
        expect(affiliate.should_show_job_organization_name?).to be false
      end
    end
  end

  describe '#default_autodiscovery_url' do
    let(:site_domains_attributes) { nil }
    let(:single_domain) { { '0' => { domain: 'usa.gov' } } }
    let(:multiple_domains) { single_domain.merge({ '1' => { domain: 'navy.mil' } }) }

    subject do
      attrs = valid_create_attributes.dup.merge({
        website: website,
        site_domains_attributes: site_domains_attributes
      }).reject { |k,v| v.nil? }
      described_class.create!(attrs)
    end

    context 'when the website is empty' do
      let(:website) { nil }
      its(:default_autodiscovery_url) { should be_nil }

      context 'when a single site_domain is provided' do
        let(:site_domains_attributes) { single_domain }
        its(:default_autodiscovery_url) { should eq('http://usa.gov') }
      end

      context 'when mutiple site_domains are provided' do
        let(:site_domains_attributes) { multiple_domains }
        its(:default_autodiscovery_url) { should be_nil }
      end
    end

    context 'when the website is present' do
      let(:website) { valid_create_attributes[:website] }
      its(:default_autodiscovery_url) { should eq(website) }

      context 'when a single site_domain is provided' do
        let(:site_domains_attributes) { single_domain }
        its(:default_autodiscovery_url) { should eq(website) }
      end

      context 'when mutiple site_domains are provided' do
        let(:site_domains_attributes) { multiple_domains }
        its(:default_autodiscovery_url) { should eq(website) }
      end
    end
  end

  describe '#enable_video_govbox!' do
    let(:affiliate) { affiliates(:gobiernousa_affiliate) }
    before do
      youtube_profile = youtube_profiles(:whitehouse)
      affiliate.youtube_profiles << youtube_profile
      affiliate.enable_video_govbox!
    end

    it 'should localize "Videos" for the name of the RSS feed' do
      expect(affiliate.rss_feeds.last.name).to eq('Vídeos')
    end
  end

  describe '#dup' do
    let(:original_instance) do
      css_property_hash = {
        'title_link_color' => '#33ff33',
        'visited_title_link_color' => '#0000ff'
      }
      site = described_class.create!(css_property_hash: css_property_hash,
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
                                     theme: 'custom')
      described_class.find site.id
    end

    include_examples 'dupable',
                     %w[api_access_key
                        header_tagline_logo_content_type
                        header_tagline_logo_file_name
                        header_tagline_logo_file_size
                        header_tagline_logo_updated_at
                        mobile_logo_content_type
                        mobile_logo_file_name
                        mobile_logo_file_size
                        mobile_logo_updated_at
                        name]

    it 'sets @css_property_hash instance variable' do
      expect(subject.instance_variable_get(:@css_property_hash)).to include(:title_link_color, :visited_title_link_color)
    end
  end

  describe 'has_many :affiliate_templates' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:template_rounded) { affiliate_templates(:usagov_rounded_header_link) }

    describe '#load_template_schema' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it 'loads the templates Schema if no schema is stored in DB' do
        expect(affiliate.load_template_schema).to eq(Template.default.schema)
      end

      it 'loads the saved Schema if stored in DB' do
        changed_to_schema = {'css' => 'Test Schema'}.to_json
        affiliate.update_attribute(:template_schema, changed_to_schema)
        affiliate.reload
        expect(affiliate.load_template_schema.to_json).to eq(changed_to_schema)
      end
    end

    describe '#save_template_schema' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it 'merges defaults and saves the schema' do
        allow(Template).to receive_message_chain(:default, :schema).and_return({'schema' => {'default' => 'default' }})
        affiliate.save_template_schema({ 'schema' => {'test_schema' => 'test'}})
        expect(affiliate.load_template_schema).to eq(Hashie::Mash.new({'schema'=>{'default'=>'default', 'test_schema'=>'test'}}))
      end

      it 'loads the schema if not blank, merges new values and saves the schema' do
        affiliate.template_schema = {'schema' => {'default' => 'default' }}.to_json
        affiliate.save
        affiliate.reload

        affiliate.save_template_schema({ 'schema' => {'test_schema' => 'test'}})
        expected_schema = {'schema'=>{'default'=>'default', 'test_schema'=>'test'}}
        expect(affiliate.load_template_schema).to eq(expected_schema)
      end

    end

    describe '#reset_template_schema' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it 'resets the schema' do
        affiliate.update_attribute(:template_schema, {'test' => 'test'}.to_json)
        allow(Template).to receive_message_chain(:default, :schema).and_return({'css' => {'default' => 'default' }})
        expect(affiliate.reset_template_schema).to eq(Hashie::Mash.new({'css'=>{'default'=>'default'}}))
      end
    end

    describe '#port_classic_theme' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      it 'merges existing colors into template_schema' do
        affiliate.update_attributes({
          'css_property_hash'=>{
            'header_tagline_font_size'=>nil,
            'content_background_color'=>'#FFFFFF',
            'description_text_color'=>'#000000',
            'footer_background_color'=>'#DFDFDF',
            'footer_links_text_color'=>'#000000',
            'header_links_background_color'=>'#0068c4',
            'header_links_text_color'=>'#fff',
            'header_text_color'=>'#000000',
            'header_background_color'=>'#FFFFFF',
            'header_tagline_background_color'=>'#000000',
            'header_tagline_color'=>'#FFFFFF',
            'search_button_text_color'=>'#FFFFFF',
            'search_button_background_color'=>'#00396F',
            'left_tab_text_color'=>'#9E3030',
            'navigation_background_color'=>'#F1F1F1',
            'navigation_link_color'=>'#505050',
            'page_background_color'=>'#99999',
            'title_link_color'=>'#2200CC',
            'url_link_color'=>'#006800',
            'visited_title_link_color'=>'#800080',
            'font_family'=>'Arial, sans-serif',
            'header_tagline_font_family'=>'Georgia, "Times New Roman", serif',
            'header_tagline_font_style'=>'italic'
          },
          'theme'=>'custom'
        })
        affiliate.port_classic_theme

        expect(affiliate.load_template_schema.css.colors.header.header_text_color).to eq '#000000'

      end
    end
  end

  describe 'image assets' do
    let(:image) { File.open(Rails.root.join('spec/fixtures/images/corgi.jpg')) }
    let(:image_attributes) do
      %i{ mobile_logo header_tagline_logo }
    end
    let(:images) do
      { mobile_logo:           image,
        header_tagline_logo:   image }
    end
    let(:affiliate) do
      described_class.create(valid_create_attributes.merge(images))
    end

    it 'stores the images in s3 with a secure url' do
      image_attributes.each do |image|
        expect(affiliate.send(image).url).to match /https:\/\/.*\.s3\.amazonaws\.com\/test\/site\/#{affiliate.id}\/#{image}\/\d+\/original\/corgi.jpg/

      end
    end
  end

  describe '#template' do
    context 'when no template has been assigned' do
      let(:affiliate) { described_class.new }
      it 'returns the default template' do
        expect(affiliate.template.name).to eq 'Classic'
      end
    end
  end

  # This will be torn out eventually along with the rest of the
  # deprecated search-consumer code: SRCHAR-2713
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
  end

  describe '#sc_search_engine' do
    subject { described_class.new(valid_create_attributes.merge(search_engine: search_engine)) }

    {
      'Bing' => 'Bing',
      'BingV6' => 'Bing',
      'BingV7' => 'Bing',
      'Google' => 'Google'
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
