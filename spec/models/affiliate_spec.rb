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
    it { should ensure_length_of(:name).is_at_least(3).is_at_most(33) }
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

    it "should have Affiliate-specific SAYT suggestions enabled by default" do
      Affiliate.create!(@valid_create_attributes).is_affiliate_suggestions_enabled.should be_true
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
    it "should return all staging attributes" do
      affiliate = Affiliate.create(@valid_create_attributes)
      affiliate.staging_attributes.include?(:staged_domains).should be_true
      affiliate.staging_attributes.include?(:staged_header).should be_true
      affiliate.staging_attributes.include?(:staged_footer).should be_true
      affiliate.staging_attributes.include?(:staged_affiliate_template_id).should be_true
      affiliate.staging_attributes.include?(:staged_search_results_page_title).should be_true
      affiliate.staging_attributes[:staged_domains].should == affiliate.staged_domains
      affiliate.staging_attributes[:staged_header].should == affiliate.staged_header
      affiliate.staging_attributes[:staged_footer].should == affiliate.staged_footer
      affiliate.staging_attributes[:staged_affiliate_template_id] == affiliate.staged_affiliate_template_id
      affiliate.staging_attributes[:staged_search_results_page_title] == affiliate.staged_search_results_page_title
    end
  end

  describe "#cancel_staged_changes" do
    let(:affiliate) { Affiliate.create!(@valid_create_attributes) }

    before do
      @update_params = {:staged_domains => "updated.domain.gov",
                        :staged_header => "<span>header</span>",
                        :staged_footer => "<span>footer</span>",
                        :staged_affiliate_template_id => affiliate_templates(:basic_gray).id,
                        :staged_search_results_page_title => "updated - {query} - {sitename} Search Results"}
      affiliate.update_attributes_for_staging(@update_params)
    end

    it "should overwrite all staged attributes with non staged attributes" do
      affiliate.cancel_staged_changes
      affiliate.staged_domains.should_not == @update_params[:staged_domains]
      affiliate.staged_header.should_not == @update_params[:staged_header]
      affiliate.staged_footer.should_not == @update_params[:staged_footer]
      affiliate.staged_affiliate_template_id.should_not == @update_params[:staged_affiliate_template_id]
      affiliate.staged_search_results_page_title.should_not == @update_params[:staged_search_results_page_title]
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
                                                                   :staged_footer => "staged footer"))
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
end
