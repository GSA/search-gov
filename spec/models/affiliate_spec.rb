require 'spec/spec_helper'

describe Affiliate do
  fixtures :users, :affiliates, :affiliate_templates

  before(:each) do
    @valid_create_attributes = {
      :display_name => "My Awesome Site",
      :domains => "someaffiliate.gov",
      :website => "http://www.someaffiliate.gov",
      :header => "<table><tr><td>html layout from 1998</td></tr></table>",
      :footer => "<center>gasp</center>"
    }
    @valid_attributes = @valid_create_attributes.merge(:name => "someaffiliate.gov")
  end

  describe "Creating new instance of Affiliate" do
    it { should validate_presence_of :display_name }
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
    it { should have_many :calais_related_searches }
    it { should have_many(:popular_urls).dependent(:destroy) }
    it { should have_many(:featured_collections).dependent(:destroy) }
    it { should have_many(:rss_feeds).dependent(:destroy) }
    it { should belong_to :affiliate_template }
    it { should belong_to :staged_affiliate_template }

    it "should create a new instance given valid attributes" do
      Affiliate.create!(@valid_create_attributes)
    end

    it "should generate HTTP parameter site name based on display name" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "Affiliate site"))
      affiliate.name.should == "affiliatesite"
    end

    describe "on create" do
      it "should generate HTTP parameter site name based on MD5 hash value when the display name is too short" do
        Digest::MD5.should_receive(:hexdigest).and_return("hexvalue")
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "A"))
        affiliate.name.should == "hexvalue"
      end

      it "should generate HTTP parameter site name based on MD5 hash value if display name contains less than 3 valid characters" do
        Digest::MD5.should_receive(:hexdigest).and_return("hexvalue")
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "3!!"))
        affiliate.name.should == "hexvalue"
      end

      it "should generate HTTP parameter site name using MD5 hash value when the candidate HTTP parameter site name already exists" do
        Digest::MD5.should_receive(:hexdigest).and_return("hexvalue")
        first_affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "Affiliate site123___----...."))
        first_affiliate.name.should == "affiliatesite123___----...."
        second_affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "Affiliate site123___----...."))
        second_affiliate.name.should == "hexvalue"
      end

      it "should generate HTTP parameter site name with 33 characters if display name is greater than 33 characters" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "1234567890!!1234567890!!1234567890!!123456"))
        affiliate.name.should == "123456789012345678901234567890123"
      end

      it "should generate HTTP parameter site name with 3 characters if display name is 3 characters" do
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
    end

    describe "on update_attributes_for_staging" do
      let(:affiliate) { Affiliate.create!(@valid_create_attributes) }

      before do
        @update_params = {:staged_domains => "updated.domain.gov",
                          :staged_header => "<span>header</span>",
                          :staged_footer => "<span>footer</span>",
                          :staged_affiliate_template_id => affiliate_templates(:basic_gray).id,
                          :staged_search_results_page_title => "updated - {query} - {sitename} Search Results"}
      end

      it "should set has_staged_content to true" do
        affiliate.has_staged_content.should be_false
        affiliate.update_attributes_for_staging(@update_params).should be_true
        affiliate.has_staged_content.should be_true
      end

      it "should update staged attributes" do
        affiliate.update_attributes_for_staging(@update_params).should be_true
        affiliate.staged_domains.should == @update_params[:staged_domains]
        affiliate.staged_header.should == @update_params[:staged_header]
        affiliate.staged_footer.should == @update_params[:staged_footer]
        affiliate.staged_affiliate_template_id.should == @update_params[:staged_affiliate_template_id]
        affiliate.staged_search_results_page_title.should == @update_params[:staged_search_results_page_title]
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
    end

    describe "on update_attributes_for_current" do
      let(:affiliate) { Affiliate.create!(@valid_create_attributes) }

      before do
        @update_params = {:staged_domains => "updated.domain.gov",
                          :staged_header => "<span>header</span>",
                          :staged_footer => "<span>footer</span>",
                          :staged_affiliate_template_id => affiliate_templates(:basic_gray).id,
                          :staged_search_results_page_title => "updated - {query} - {sitename} Search Results"}
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
        affiliate.domains.should == @update_params[:staged_domains]
        affiliate.header.should == @update_params[:staged_header]
        affiliate.footer.should == @update_params[:staged_footer]
        affiliate.affiliate_template_id.should == @update_params[:staged_affiliate_template_id]
        affiliate.search_results_page_title.should == @update_params[:staged_search_results_page_title]
        affiliate.staged_domains.should == @update_params[:staged_domains]
        affiliate.staged_header.should == @update_params[:staged_header]
        affiliate.staged_footer.should == @update_params[:staged_footer]
        affiliate.staged_affiliate_template_id.should == @update_params[:staged_affiliate_template_id]
        affiliate.staged_search_results_page_title.should == @update_params[:staged_search_results_page_title]
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
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
      Affiliate.find(affiliate.id).update_attributes(:affiliate_template_id => "")
      Affiliate.find(affiliate.id).affiliate_template.should == affiliate_templates(:default)
    end

    context "when input domains is nil" do
      it "should return nil" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:staged_domains => nil))
        affiliate.staged_domains.should be_nil
      end
    end

    context "when input domains have leading http(s) protocols" do
      it "should delete leading http(s) protocols from domains" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:staged_domains => "http://foo.gov\nbar.gov/somepage.html\nhttps://blat.gov/somedir"))
        affiliate.staged_domains.should == "foo.gov\nblat.gov/somedir\nbar.gov/somepage.html"
      end
    end

    context "when input domains have blank/whitespace" do
      it "should delete blank/whitespace from domains" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:staged_domains => "do.gov\n\n\n bar.gov  \nblat.gov"))
        affiliate.staged_domains.should == "do.gov\nbar.gov\nblat.gov"
      end
    end

    context "when input domains have dupes" do
      it "should delete dupes from domains" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:staged_domains => "foo.gov\nfoo.gov"))
        affiliate.staged_domains.should == "foo.gov"
      end
    end

    context "when there is just one input domain" do
      it "should return that input domain" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:staged_domains => "foo.gov"))
        affiliate.staged_domains.should == "foo.gov"
      end
    end

    context "when input domains don't look like domains" do
      it "should filter them out" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:staged_domains => "foo.gov\nsomepage.html\nwhatisthis?\nbar.gov/somedir/"))
        affiliate.staged_domains.should == "foo.gov\nbar.gov/somedir/"
      end
    end

    context "when one input domain is covered by another" do
      it "should filter it out" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:staged_domains => "blat.gov\nblat.gov/s.html\nbar.gov/somedir/\nbar.gov\nwww.bar.gov\nxxbar.gov"))
        affiliate.staged_domains.should == "bar.gov\nblat.gov\nxxbar.gov"
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
    Affiliate.human_attribute_name("name").should == "HTTP parameter site name"
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
      { :staged_domains => 'agency.gov',
        :staged_header => '<h1>staged header</h1>',
        :staged_footer => '<h1>staged footer</h1>',
        :staged_affiliate_template => affiliate_templates(:basic_gray),
        :staged_search_results_page_title => 'custom serp title',
        :staged_favicon_url => 'http://cdn.agency.gov/favicon.ico',
        :staged_external_css_url => 'http://cdn.agency.gov/custom.css' } }

    let(:staged_attributes) {
      create_staged_attributes.merge(:staged_affiliate_template_id => affiliate_templates(:basic_gray).id).except(:staged_affiliate_template)
    }

    let(:affiliate) { Affiliate.create(@valid_create_attributes.merge(create_staged_attributes)) }

    context "when initialized" do
      it "should return all staging attributes" do
        [:staged_domains, :staged_header, :staged_footer,
         :staged_affiliate_template_id, :staged_search_results_page_title,
         :staged_favicon_url, :staged_external_css_url].each do |key|
          affiliate.staging_attributes.should include(key)
        end
      end

      specify { affiliate.staging_attributes.should == staged_attributes }
    end
  end

  describe "#cancel_staged_changes" do
    let(:affiliate) { Affiliate.create!(@valid_create_attributes) }

    before do
      @update_params = { :staged_domains => "updated.domain.gov",
                         :staged_header => "<span>header</span>",
                         :staged_footer => "<span>footer</span>",
                         :staged_affiliate_template_id => affiliate_templates(:basic_gray).id,
                         :staged_search_results_page_title => "updated - {query} - {sitename} Search Results",
                         :staged_favicon_url => 'http://cdn.agency.gov/staged_favicon.ico',
                         :staged_external_css_url => "http://cdn.agency.gov/staged_custom.css" }
      affiliate.update_attributes_for_staging(@update_params).should be_true
    end

    it "should overwrite all staged attributes with non staged attributes" do
      affiliate.cancel_staged_changes
      affiliate.staged_domains.should_not == @update_params[:staged_domains]
      affiliate.staged_header.should_not == @update_params[:staged_header]
      affiliate.staged_footer.should_not == @update_params[:staged_footer]
      affiliate.staged_affiliate_template_id.should_not == @update_params[:staged_affiliate_template_id]
      affiliate.staged_search_results_page_title.should_not == @update_params[:staged_search_results_page_title]
      affiliate.staged_favicon_url.should_not == @update_params[:staged_favicon_url]
      affiliate.staged_external_css_url.should_not == @update_params[:staged_external_css_url]
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
    it "should overwrite staged attributes with live attributes if has_staged_content is false" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:has_staged_content => false,
                                                                   :domains => "livedomain.gov",
                                                                   :staged_domains => "stageddomain.gov",
                                                                   :affiliate_template_id => affiliate_templates(:basic_gray).id,
                                                                   :staged_affiliate_template_id => affiliate_templates(:default).id,
                                                                   :search_results_page_title => "live SERP title",
                                                                   :staged_search_results_page_title => "staged SERP title",
                                                                   :header => "live header",
                                                                   :staged_header => "staged header",
                                                                   :footer => "live footer",
                                                                   :staged_footer => "staged footer",
                                                                   :external_css_url => 'http://cdn.agency.gov/custom.css',
                                                                   :staged_external_css_url => 'http://cdn.agency.gov/staged_custom.css'))
      affiliate.has_staged_content.should == false
      affiliate.sync_staged_attributes
      affiliate.has_staged_content.should == false
      affiliate.domains.should == "livedomain.gov"
      affiliate.staged_domains.should == "livedomain.gov"
      affiliate.affiliate_template_id.should == affiliate_templates(:basic_gray).id
      affiliate.staged_affiliate_template_id.should == affiliate_templates(:basic_gray).id
      affiliate.search_results_page_title.should == "live SERP title"
      affiliate.staged_search_results_page_title.should == "live SERP title"
      affiliate.header.should == "live header"
      affiliate.staged_header.should == "live header"
      affiliate.footer.should == "live footer"
      affiliate.staged_footer.should == "live footer"
      affiliate.external_css_url.should == 'http://cdn.agency.gov/custom.css'
      affiliate.staged_external_css_url.should == 'http://cdn.agency.gov/custom.css'
    end

    it "should not overwrite staged attributes with live attributes if has_staged_content is true" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:has_staged_content => true,
                                                                   :domains => "livedomain.gov",
                                                                   :staged_domains => "stageddomain.gov",
                                                                   :affiliate_template_id => affiliate_templates(:basic_gray).id,
                                                                   :staged_affiliate_template_id => affiliate_templates(:default).id,
                                                                   :search_results_page_title => "live SERP title",
                                                                   :staged_search_results_page_title => "staged SERP title",
                                                                   :header => "live header",
                                                                   :staged_header => "staged header",
                                                                   :footer => "live footer",
                                                                   :staged_footer => "staged footer"))
      affiliate.has_staged_content.should == true
      affiliate.sync_staged_attributes
      affiliate.has_staged_content.should == true
      affiliate.domains.should == "livedomain.gov"
      affiliate.staged_domains.should == "stageddomain.gov"
      affiliate.affiliate_template_id.should == affiliate_templates(:basic_gray).id
      affiliate.staged_affiliate_template_id.should == affiliate_templates(:default).id
      affiliate.search_results_page_title.should == "live SERP title"
      affiliate.staged_search_results_page_title.should == "staged SERP title"
      affiliate.header.should == "live header"
      affiliate.staged_header.should == "staged header"
      affiliate.footer.should == "live footer"
      affiliate.staged_footer.should == "staged footer"
    end
  end

  describe "#domains_as_array" do
    before do
      @affiliate = Affiliate.new(:domains => "domain.com\nanother.domain.com")
    end

    it "should return an array" do
      @affiliate.domains_as_array.is_a?(Array).should be_true
    end

    it "should have two entries split on line break" do
      @affiliate.domains_as_array.size.should == 2
      @affiliate.domains_as_array.first.should == "domain.com"
      @affiliate.domains_as_array.last.should == "another.domain.com"
    end

    context "when domains is nil" do
      before do
        @affiliate.domains = nil
      end

      it "should not error when called, and return empty" do
        @affiliate.domains_as_array.should == []
      end
    end
  end

  describe "#has_multiple_domains?" do
    context "when Affiliate has more than 1 domain" do
      let(:affiliate) { Affiliate.new(:domains => "   foo.com\n  bar.com") }
      subject { affiliate }
      its(:has_multiple_domains?) { should be_true }
    end

    context "when Affiliate has no domain" do
      let(:affiliate) { Affiliate.new }
      subject { affiliate }
      its(:has_multiple_domains?) { should be_false }
    end

    context "when Affiliate has 1 domain" do
      let(:affiliate) { Affiliate.new(:domains => "  foo.com \n\n") }
      subject { affiliate }
      its(:has_multiple_domains?) { should be_false }
    end
  end

  describe "#get_matching_domain" do
    let(:affiliate) { Affiliate.new(:domains => "   foo.com\n  bar.com") }
    let(:url_within_domain) { "http://www.bar.com/blogs/1" }
    let(:url_outside_domain) { "http://www.outsider.com/blogs/1" }

    context "when locale is :en" do
      before do
        I18n.stub(:locale).and_return(:en)
      end

      context "and url is in the same domain" do
        specify { affiliate.get_matching_domain(url_within_domain).should == "bar.com" }
      end

      context "and url is not in the same domain" do
        specify { affiliate.get_matching_domain(url_outside_domain).should be_blank }
      end
    end

    context "when locale is :es" do
       before do
        I18n.stub(:locale).and_return(:es)
      end

      context "and url is within the domain" do
        specify { affiliate.get_matching_domain(url_within_domain).should be_blank }
      end

      context "and url is outside the domain" do
        specify { affiliate.get_matching_domain(url_outside_domain).should be_blank }
      end
    end
  end
end
