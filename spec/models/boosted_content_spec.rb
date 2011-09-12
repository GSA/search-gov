require 'spec/spec_helper'

describe BoostedContent do
  fixtures :affiliates
  before(:each) do
    @valid_attributes = {
      :url => "http://www.someaffiliate.gov/foobar",
      :title => "The foobar page",
      :description => "All about foobar, boosted to the top",
      :affiliate => affiliates(:power_affiliate),
      :keywords => 'unrelated, terms',
      :locale => 'en',
      :auto_generated => false,
      :status => 'active',
      :publish_start_on => Date.current
    }
  end

  describe "Creating new instance of BoostedContent" do
    it { should validate_presence_of :url }
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :locale }
    SUPPORTED_LOCALES.each do |locale|
      it { should allow_value(locale).for(:locale) }
    end
    ["tz", "ps"].each do |locale|
      it { should_not allow_value(locale).for(:locale) }
    end
    it { should validate_presence_of :publish_start_on }

    BoostedContent::STATUSES.each do |status|
      it { should allow_value(status).for(:status) }
    end
    it { should_not allow_value("bogus status").for(:status) }

    specify { BoostedContent.new(:status => 'active').should be_is_active }
    specify { BoostedContent.new(:status => 'active').should_not be_is_inactive }
    specify { BoostedContent.new(:status => 'inactive').should be_is_inactive }
    specify { BoostedContent.new(:status => 'inactive').should_not be_is_active }

    it { should belong_to :affiliate }

    it "should create a new instance given valid attributes" do
      BoostedContent.create!(@valid_attributes)
    end

    it "should default the locale to 'en'" do
      BoostedContent.create!(@valid_attributes).locale.should == 'en'
    end

    it "should validate unique url" do
      BoostedContent.create!(@valid_attributes)
      duplicate = BoostedContent.new(@valid_attributes)
      duplicate.should_not be_valid
      duplicate.errors[:url].first.should =~ /already been boosted/
    end

    it "should allow a duplicate url for a different affiliate" do
      BoostedContent.create!(@valid_attributes)
      duplicate = BoostedContent.new(@valid_attributes.merge(:affiliate => affiliates(:basic_affiliate)))
      duplicate.should be_valid
    end

    it "should allow nil keywords" do
      BoostedContent.create!(@valid_attributes.merge(:keywords => nil))
    end

    it "should allow an empty keywords value" do
      BoostedContent.create!(@valid_attributes.merge(:keywords => ""))
    end

    it "should not allow publish start date before publish end date" do
      boosted_content = BoostedContent.create(@valid_attributes.merge({ :publish_start_on => '07/01/2012', :publish_end_on => '07/01/2011' }))
      boosted_content.errors.full_messages.join.should =~ /Publish end date can't be before publish start date/
    end

    it "should save URL with http:// prefix when it does not start with http(s)://" do
      url = 'searchblog.usa.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        boosted_content = BoostedContent.create!(@valid_attributes.merge(:url => "#{prefix}#{url}"))
        boosted_content.url.should == "http://#{prefix}#{url}"
      end
    end

    it "should save URL as is when it starts with http(s)://" do
      url = 'searchblog.usa.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        boosted_content = BoostedContent.create!(@valid_attributes.merge(:url => "#{prefix}#{url}"))
        boosted_content.url.should == "#{prefix}#{url}"
      end
    end
  end

  describe "#human_attribute_name" do
    specify { BoostedContent.human_attribute_name("publish_start_on").should == "Publish start date" }
    specify { BoostedContent.human_attribute_name("publish_end_on").should == "Publish end date" }
    specify { BoostedContent.human_attribute_name("url").should == "URL" }
  end

  describe "#as_json" do
    it "should include title, url, and description" do
      hash = BoostedContent.create!(@valid_attributes).as_json
      hash[:title].should == @valid_attributes[:title]
      hash[:url].should == @valid_attributes[:url]
      hash[:description].should == @valid_attributes[:description]
      hash.keys.length.should == 3
    end
  end

  context "when the affiliate associated with a particular Boosted Content is destroyed" do
    fixtures :affiliates
    before do
      affiliate = Affiliate.create(:display_name => "Test Affiliate", :name => 'test_affiliate')
      BoostedContent.create(@valid_attributes.merge(:affiliate => affiliate))
      affiliate.destroy
    end

    it "should also delete the boosted Content" do
      BoostedContent.find_by_url(@valid_attributes[:url]).should be_nil
    end
  end

  context "when the affiliate associated with a particular Boosted Content is deleted, and BoostedContents are reindexed" do
    fixtures :affiliates
    before do
      affiliate = Affiliate.create(:display_name => "Test Affiliate", :name => 'test_affiliate')
      BoostedContent.create(@valid_attributes.merge(:affiliate => affiliate))
      affiliate.delete
      BoostedContent.reindex
    end

    it "should not find the orphaned boosted Content while searching for Search.USA.gov boosted Contents" do
      BoostedContent.search_for("foobar").total.should == 0
    end
  end

  context "bulk uploads" do
    fixtures :affiliates

    before :each do
      @site_xml = <<-XML
        <xml>
          <entries>
            <entry>
              <title>This is a listing about Texas</title>
              <url>http://some.url</url>
              <description>This is the description of the listing</description>
            </entry>
            <entry>
              <title>Some other listing about hurricanes</title>
              <url>http://some.other.url</url>
              <description>Another description for another listing</description>
            </entry>
          </entries>
        </xml>
      XML
    end

    it "should create and index boosted Contents from an xml document" do
      basic_affiliate = affiliates(:basic_affiliate)

      counts = BoostedContent.process_boosted_content_xml_upload_for(basic_affiliate, StringIO.new(@site_xml))

      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 2
      basic_affiliate.boosted_contents.map(&:url).should =~ ["http://some.url", "http://some.other.url"]
      basic_affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.description.should == "Another description for another listing"
      counts[:created].should == 2
      counts[:updated].should == 0
    end

    it "should update existing boosted Contents if the url match" do
      basic_affiliate = affiliates(:basic_affiliate)
      basic_affiliate.boosted_contents.create!(:url => "http://some.url", :title => "an old title", :description => "an old description", :locale => 'en', :status => 'active', :publish_start_on => Date.current)

      counts = BoostedContent.process_boosted_content_xml_upload_for(basic_affiliate, StringIO.new(@site_xml))

      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 2
      basic_affiliate.boosted_contents.all.find { |b| b.url == "http://some.url" }.title.should == "This is a listing about Texas"
      counts[:created].should == 1
      counts[:updated].should == 1
    end

    it "should merge with preexisting boosted Contents" do
      basic_affiliate = affiliates(:basic_affiliate)
      basic_affiliate.boosted_contents.create!(:url => "http://a.different.url", :title => "title", :description => "description", :locale => 'en', :status => 'active', :publish_start_on => Date.current)

      counts = BoostedContent.process_boosted_content_xml_upload_for(basic_affiliate, StringIO.new(@site_xml))

      basic_affiliate.reload
      basic_affiliate.boosted_contents.length.should == 3
      basic_affiliate.boosted_contents.map(&:url).should =~ ["http://some.url", "http://some.other.url", "http://a.different.url"]
      counts[:created].should == 2
      counts[:updated].should == 0
    end
  end

  describe "#search_for" do
    before do
      @affiliate = affiliates(:power_affiliate)
    end

    context "when the term is not mentioned in the description" do
      before do
        @boosted_content = BoostedContent.create!(@valid_attributes)
        Sunspot.commit
        BoostedContent.reindex
      end

      it "should find a boosted content by keyword" do
        search = BoostedContent.search_for('unrelated', @affiliate)
        search.total.should == 1
        search.results.first.should == @boosted_content
      end
    end

    context "when the affiliate is specified" do
      it "should instrument the call to Solr with the proper action.service namespace, affiliate, and query param hash" do
        ActiveSupport::Notifications.should_receive(:instrument).
          with("solr_search.usasearch", hash_including(:query => hash_including(:affiliate => @affiliate.name, :model=>"BoostedContent", :term => "foo", :locale=>"en")))
        BoostedContent.search_for('foo', @affiliate)
      end
    end

    context "when the affiliate is not specified" do
      it "should instrument the call to Solr with the proper action.service namespace, default affiliate, and query param hash" do
        ActiveSupport::Notifications.should_receive(:instrument).
          with("solr_search.usasearch", hash_including(:query => hash_including(:affiliate => Affiliate::USAGOV_AFFILIATE_NAME, :model=>"BoostedContent", :term => "foo", :locale => "en")))
        BoostedContent.search_for('foo')
      end
    end
  end

  describe "#display_status" do
    context "when status is set to active" do
      subject { BoostedContent.new(:status => 'active') }
      its(:display_status) { should == 'Active' }
    end

    context "when status is set to inactive" do
      subject { BoostedContent.new(:status => 'inactive') }
      its(:display_status) { should == 'Inactive' }
    end
  end
end
