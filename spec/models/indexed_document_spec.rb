# coding: utf-8
require 'spec_helper'

describe IndexedDocument do
  fixtures :affiliates, :superfresh_urls, :site_domains, :indexed_domains, :features
  before do
    @min_valid_attributes = {
      :url => "http://min.nps.gov/link.html",
      :affiliate_id => affiliates(:basic_affiliate).id
    }
    @valid_attributes = {
      :title => 'Some Title',
      :description => 'This is a document.',
      :url => 'http://www.nps.gov/index.htm',
      :doctype => 'html',
      :last_crawl_status => IndexedDocument::OK_STATUS,
      :body => "this is the doc body",
      :affiliate_id => affiliates(:basic_affiliate).id,
      :content_hash => "a6e450cc50ac3b3b7788b50b3b73e8b0b7c197c8"
    }
    BingSearch.stub(:search_for_url_in_bing).and_return(nil)
  end

  it { should validate_presence_of :url }
  it { should validate_presence_of :affiliate_id }
  it { should allow_value("http://some.site.gov/url").for(:url) }
  it { should allow_value("http://some.site.mil/").for(:url) }
  it { should allow_value("http://some.govsite.com/url").for(:url) }
  it { should allow_value("http://some.govsite.us/url").for(:url) }
  it { should allow_value("http://some.govsite.info/url").for(:url) }
  it { should allow_value("https://some.govsite.info/url").for(:url) }
  it { should_not allow_value("http://something.gov/there_is_a_space_in_this url.pdf").for(:url) }
  it { should_not allow_value("http://www.ssa.gov./trailing-period-in-domain.pdf").for(:url) }
  it { should belong_to :affiliate }
  it { should have_and_belong_to_many :forms }

  context "when associated affiliate has an excluded domain list" do
    before do
      affiliate = affiliates(:basic_affiliate)
      affiliate.add_site_domains('site1.gov' => nil, 'site2.gov' => nil)
      affiliate.excluded_domains.build(:domain => "beta.site1.gov")
      affiliate.excluded_domains.build(:domain => "site2.gov/subdir")
      affiliate.save!
    end

    context "when URL of indexed document matches something in affiliate's excluded domain list" do
      it "should find the record invalid" do
        %w(http://beta.site1.gov/foo http://www.site2.gov/subdir/doc.html).each do |url|
          odie = IndexedDocument.new(@valid_attributes.merge(url: url))
          odie.save.should be_false
          odie.errors.full_messages.join(' ').should =~ /#{IndexedDocument::DOMAIN_EXCLUDED_STATUS}/
        end
      end
    end

    context "when URL of indexed document doesn't match anything in affiliate's excluded domain list" do
      it "should find the record valid given all other attributes are valid" do
        %w(http://ok.site1.gov/foo http://www.site2.gov/subdir2/doc.html).each do |url|
          IndexedDocument.new(@valid_attributes.merge(:url => url)).should be_valid
        end
      end
    end
  end

  context "when associated affiliate has a site domain list" do
    before do
      SiteDomain.create!(:affiliate => affiliates(:basic_affiliate), :domain => "whitelist.gov/someurl")
      SiteDomain.create!(:affiliate => affiliates(:basic_affiliate), :domain => ".mil")
      SiteDomain.create!(:affiliate => affiliates(:basic_affiliate), :domain => "www.ftc.gov")
    end

    context "when URL of indexed document doesn't match anything in affiliate's site domain list" do
      it "should find the record invalid" do
        %w(http://www.blacklisted.gov/foo/http://www.whitelist.gov/someurl/page.pdf
           whitelist.gov/blog/someurl/1.html
           http://www.ftc.gov.backwards.u.is/doc.html
           http://www1ftc.gov/doc.html).each do |url|
          odie = IndexedDocument.new(@valid_attributes.merge(url: url))
          odie.save.should be_false
          odie.errors.full_messages.join(' ').should =~ /#{IndexedDocument::DOMAIN_MISMATCH_STATUS}/
        end
      end
    end

    context "when URL of indexed document matches something in affiliate's site domain list" do
      it "should find the record valid given all other attributes are valid" do
        %w{http://www.WHITELIST.gov/someurl/page.pdf http://www.army.mil/someurl/page.pdf}.each do |url|
          IndexedDocument.new(@valid_attributes.merge(:url => url)).should be_valid
        end
      end
    end
  end

  context "when associated affiliate has no site domains" do
    before do
      affiliates(:basic_affiliate).site_domains.destroy_all
    end

    it "should find the record invalid" do
      IndexedDocument.new(@valid_attributes.merge(:url => "http://www.nps.gov/foo.pdf")).should_not be_valid
    end
  end

  context "when robots.txt info exists for the domain" do
    before do
      Robot.create!(:domain => 'nps.gov', :prefixes => '/test/,/test2/')
    end

    context "when there is a match" do
      it "should mark the record invalid" do
        idoc = IndexedDocument.new(@valid_attributes.merge(:url => 'http://nps.gov/test/no.pdf'))
        idoc.should_not be_valid
        idoc.errors.full_messages.first.should == IndexedDocument::ROBOTS_TXT_COMPLIANCE
      end
    end

    context "when there is no match" do
      it "should not mark the record invalid" do
        IndexedDocument.new(@valid_attributes.merge(:url => 'http://nps.gov/ok/test/no.pdf')).should be_valid
      end
    end
  end

  context "when a URL is a valid candidate for Odie indexing" do
    let(:idoc) { IndexedDocument.new(@valid_attributes) }
    let(:normalized_url) { 'nps.gov/index.htm' }

    context "when the URL exists in Bing" do
      before do
        BingUrl.delete_all
        BingUrl.create!(:normalized_url => 'whitehouse.gov/blog/2012/09/25/president-obama-addresses-united-nations')
        BingSearch.should_receive(:search_for_url_in_bing).and_return(normalized_url)
      end

      it "should be invalid" do
        idoc.save.should be_false
        idoc.errors.full_messages.first.should == IndexedDocument::BING_PRESENCE
        BingUrl.find_by_normalized_url(normalized_url).should be_present
      end
    end

    context "when the URL does not exist in Bing" do
      before { BingUrl.delete_all }

      it "should be valid" do
        idoc.save!
        BingUrl.find_by_normalized_url(normalized_url).should be_nil
      end
    end
  end

  context 'when a URL is not a valid candidate for Odie indexing' do
    let(:normalized_url) { 'google.com' }
    let(:idoc) { IndexedDocument.new(@valid_attributes.merge(:url => normalized_url)) }

    it 'should not check for bing absence' do
      BingSearch.should_not_receive(:search_for_url_in_bing)
      idoc.save.should be_false
    end
  end

  it "should mark invalid URLs that have an extension that we have blacklisted" do
    movie = "http://www.nps.gov/some.mov"
    idoc = IndexedDocument.new(@valid_attributes.merge(:url => movie))
    idoc.should_not be_valid
    idoc.errors.full_messages.first.should == IndexedDocument::UNSUPPORTED_EXTENSION
  end

  it "should cap URL length at 2000 characters" do
    too_long = "http://www.nps.gov/#{'waytoolong'*200}/some.pdf"
    idoc = IndexedDocument.new(@valid_attributes.merge(:url => too_long))
    idoc.should_not be_valid
    idoc.errors[:url].first.should =~ /too long/
  end

  it "should assign/create an associated indexed_domain" do
    IndexedDocument.create!(@valid_attributes)
    IndexedDomain.find_by_affiliate_id_and_domain(affiliates(:basic_affiliate).id, "www.nps.gov").should_not be_nil
  end

  describe "normalizing URLs when saving" do
    context "when URL doesn't have a protocol" do
      let(:url) { "www.nps.gov/sdfsdf" }
      it "should prepend it with http://" do
        IndexedDocument.create!(@valid_attributes.merge(:url => url)).url.should == "http://www.nps.gov/sdfsdf"
      end
    end

    context "when an URL contains an anchor tag" do
      let(:url) { "http://www.nps.gov/sdfsdf#anchorme" }
      it "should remove it" do
        IndexedDocument.create!(@valid_attributes.merge(:url => url)).url.should == "http://www.nps.gov/sdfsdf"
      end
    end

    context "when URL is mixed case" do
      let(:url) { "HTTP://Www.nps.GOV/UsaGovLovesToCapitalize?x=1#anchorme" }
      it "should downcase the scheme and host only" do
        IndexedDocument.create!(@valid_attributes.merge(:url => url)).url.should == "http://www.nps.gov/UsaGovLovesToCapitalize?x=1"
      end
    end

    context "when URL is missing trailing slash for a scheme+host URL" do
      let(:url) { "http://www.nps.gov" }
      it "should append a /" do
        IndexedDocument.create!(@valid_attributes.merge(:url => url)).url.should == "http://www.nps.gov/"
      end
    end

    context "when URL contains duplicate leading slashes in request" do
      let(:url) { "http://www.nps.gov//hey/I/am/usagov/and/love/extra////slashes.shtml" }
      it "should collapse the slashes" do
        IndexedDocument.create!(@valid_attributes.merge(:url => url)).url.should == "http://www.nps.gov/hey/I/am/usagov/and/love/extra/slashes.shtml"
      end
    end
  end

  it "should create a SuperfreshUrl entry for the affiliate" do
    SuperfreshUrl.find_by_url_and_affiliate_id(@min_valid_attributes[:url], @min_valid_attributes[:affiliate_id]).should be_nil
    IndexedDocument.create!(@min_valid_attributes)
    SuperfreshUrl.find_by_url_and_affiliate_id(@min_valid_attributes[:url], @min_valid_attributes[:affiliate_id]).should_not be_nil
  end

  it "should validate unique url" do
    IndexedDocument.create!(@valid_attributes)
    duplicate = IndexedDocument.new(@valid_attributes)
    duplicate.should_not be_valid
    duplicate.errors[:url].first.should =~ /already been added/
  end

  it "should allow a duplicate url for a different affiliate" do
    IndexedDocument.create!(@valid_attributes)
    affiliates(:power_affiliate).site_domains.create!(:domain => affiliates(:basic_affiliate).site_domains.first.domain)
    duplicate = IndexedDocument.new(@valid_attributes.merge(:affiliate_id => affiliates(:power_affiliate).id))
    duplicate.should be_valid
  end

  it "should validate unique content hash across URLs for a given affiliate" do
    attrs = @valid_attributes.merge(:content_hash => '92ebcfafee3260a041f9624525a45328')
    IndexedDocument.create!(attrs)
    duplicate = IndexedDocument.new(attrs.merge(:url => "http://www.nps.gov/myurl.html"))
    duplicate.should_not be_valid
    duplicate.errors[:content_hash].first.should =~ /Identical content/
    affiliates(:power_affiliate).site_domains.create!(:domain => affiliates(:basic_affiliate).site_domains.first.domain)
    duplicate = IndexedDocument.new(attrs.merge(:affiliate_id => affiliates(:power_affiliate).id))
    duplicate.should be_valid
  end

  it "should validate URL against URI.parse to catch things that aren't caught in the regexp" do
    odie = IndexedDocument.new(:affiliate_id => affiliates(:basic_affiliate).id, :url => "http://www.gov.gov/pipesare||bad")
    odie.valid?.should be_false
    odie.errors.full_messages.first.should == IndexedDocument::UNPARSEABLE_URL_STATUS
  end

  it "should not allow setting last_crawl_status to OK if the title is blank" do
    odie = IndexedDocument.create!(@min_valid_attributes)
    odie.update_attributes(:title => nil, :description => 'bogus description', :last_crawl_status => IndexedDocument::OK_STATUS).should be_false
    odie.errors[:title].first.should =~ /can't be blank/
  end

  it "should not allow setting last_crawl_status to OK if the description is blank" do
    odie = IndexedDocument.create!(@min_valid_attributes)
    odie.update_attributes(:title => 'bogus title', :description => ' ', :last_crawl_status => IndexedDocument::OK_STATUS).should be_false
    odie.errors[:description].first.should =~ /can't be blank/
  end

  describe "deleting an IndexedDocument" do
    context "when it doesn't have an IndexedDomain associated with it" do
      before do
        @indexed_document = IndexedDocument.create(@min_valid_attributes)
      end

      it "should still work" do
        @indexed_document.indexed_domain.should be_nil
        @indexed_document.destroy
      end
    end

    context "when it's the last IndexedDocument associated with an IndexedDomain" do
      before do
        IndexedDocument.destroy_all
        @indexed_document = IndexedDocument.create!(@valid_attributes)
        @indexed_document.update_attributes!(:title => 'bogus title', :description => 'description', :last_crawl_status => IndexedDocument::OK_STATUS, :content_hash => '92ebcfafee3260a041f9624525a45328')
        IndexedDocument.create!(@valid_attributes.merge(:url => "http://www.nps.gov/second.html"))
      end

      it "should delete the associated orphaned IndexedDomain, too" do
        IndexedDocument.last.destroy
        IndexedDomain.find_by_domain("www.nps.gov").should_not be_nil
        IndexedDocument.last.destroy
        IndexedDomain.find_by_domain("www.nps.gov").should be_nil
      end
    end
  end

  describe "#search_for" do
    before do
      @affiliate = affiliates(:basic_affiliate)
    end

    context "when the affiliate is not specified" do
      it "should return nil" do
        IndexedDocument.search_for('foo', nil, nil).should be_nil
      end
    end

    context "when the query is blank" do
      it "should return nil" do
        IndexedDocument.search_for('', @affiliate, nil).should be_nil
      end
    end

    context "when the affiliate is specified" do
      it "should instrument the call to Solr with the proper action.service namespace, affiliate, and query param hash" do
        ActiveSupport::Notifications.should_receive(:instrument).
          with("solr_search.usasearch", hash_including(:query => hash_including(:affiliate => @affiliate.name, :model => "IndexedDocument", :term => "foo")))
        IndexedDocument.search_for('foo', @affiliate, nil)
      end
    end

    context "when some documents have non-OK statuses" do
      before do
        IndexedDocument.destroy_all
        IndexedDocument.create!(:last_crawl_status => IndexedDocument::OK_STATUS, :title => 'HTML Title', :description => 'This is a HTML document.', :url => 'http://nps.gov/html.html', :affiliate_id => affiliates(:basic_affiliate).id)
        IndexedDocument.create!(:last_crawl_status => "Broken", :title => 'PDF Title', :description => 'This is a PDF document.', :url => 'http://nps.gov/pdf.pdf', :affiliate_id => affiliates(:basic_affiliate).id)
        IndexedDocument.reindex
        Sunspot.commit
      end

      it "should only return the OK ones" do
        search = IndexedDocument.search_for('document', affiliates(:basic_affiliate), nil)
        search.total.should == 1
        search.results.first.last_crawl_status.should == IndexedDocument::OK_STATUS
      end
    end

    context "when the parent affiliate's locale is English" do
      before do
        @affiliate = affiliates(:basic_affiliate)
        IndexedDocument.create!(:last_crawl_status => IndexedDocument::OK_STATUS, :title => 'pollution is bad', :description => 'speaking', :url => 'http://nps.gov/html.html', :body => "something about swimming", :affiliate_id => @affiliate.id)
        affiliates(:power_affiliate).site_domains.create!(:domain => affiliates(:basic_affiliate).site_domains.first.domain)
        IndexedDocument.create!(:last_crawl_status => IndexedDocument::OK_STATUS, :title => 'pollution is bad', :description => 'speaking', :url => 'http://nps.gov/html.html', :body => "something about swimming", :affiliate_id => affiliates(:power_affiliate).id)
        Sunspot.commit
        IndexedDocument.reindex
      end

      it "should find by title, description, and body for that affiliate, and highlight only the terms in the title and description" do
        title_search = IndexedDocument.search_for('swim pollutant', @affiliate, nil)
        title_search.total.should == 1
        title_search.hits.first.highlight(:title).should_not be_nil
        description_search = IndexedDocument.search_for('speak', @affiliate, nil)
        description_search.total.should == 1
        description_search.hits.first.highlight(:description).should_not be_nil
        body_search = IndexedDocument.search_for('swim', @affiliate, nil)
        body_search.total.should == 1
        body_search.hits.first.highlight(:body).should be_nil
      end
    end

    context "when the parent affiliate's locale is Spanish" do
      before do
        @affiliate = affiliates(:basic_affiliate)
        @affiliate.update_attribute(:locale, 'es')
        affiliates(:power_affiliate).update_attribute(:locale, 'es')
        IndexedDocument.create!(:last_crawl_status => IndexedDocument::OK_STATUS, :title => 'jugar', :description => 'hablar', :url => 'http://nps.gov/html.html', :body => "Declaraciones", :affiliate_id => @affiliate.id)
        affiliates(:power_affiliate).site_domains.create!(:domain => affiliates(:basic_affiliate).site_domains.first.domain)
        IndexedDocument.create!(:last_crawl_status => IndexedDocument::OK_STATUS, :title => 'jugar', :description => 'hablar', :url => 'http://nps.gov/html.html', :body => "Declaraciones", :affiliate_id => affiliates(:power_affiliate).id)
        Sunspot.commit
        IndexedDocument.reindex
      end

      it "should find by title, description, and body for that affiliate, and highlight only the terms in the title and description" do
        title_search = IndexedDocument.search_for('jugando', @affiliate, nil)
        title_search.total.should == 1
        title_search.hits.first.highlight(:title_text).should_not be_nil
        description_search = IndexedDocument.search_for('hablando', @affiliate, nil)
        description_search.total.should == 1
        description_search.hits.first.highlight(:description_text).should_not be_nil
        body_search = IndexedDocument.search_for('Declaraciones', @affiliate, nil)
        body_search.total.should == 1
        body_search.hits.first.highlight(:body_text).should be_nil
      end
    end

    context "when document collection is specified" do
      before do
        IndexedDocument.destroy_all
        @affiliate = affiliates(:basic_affiliate)
        @coll = @affiliate.document_collections.create!(:name => "test",
                                                        :url_prefixes_attributes => {'0' => {:prefix => 'http://www.agency.gov/'}})
        @affiliate.site_domains.create!(:domain => "ignoreme.gov")
        @coll.url_prefixes.create!(:prefix => "http://www.nps.gov/")
        IndexedDocument.create!(:last_crawl_status => IndexedDocument::OK_STATUS, :title => 'Title 1', :description => 'This is a HTML document.', :url => 'http://www.nps.gov/html.html', :affiliate_id => @affiliate.id)
        IndexedDocument.create!(:last_crawl_status => IndexedDocument::OK_STATUS, :title => 'Title 2', :description => 'This is another HTML document.', :url => 'http://www.ignoreme.gov/html.html', :affiliate_id => @affiliate.id)
        Sunspot.commit
      end

      it "should only return results from URLs matching prefixes from that collection" do
        search = IndexedDocument.search_for('document', @affiliate, @coll)
        search.total.should == 1
        search.results.first.title.should == "Title 1"
      end
    end

    context "when the query only special characters" do
      before do
        IndexedDocument.should_not_receive(:search)
      end

      [' " ', ' + ', '-', '++', '-+', '&&'].each do |query|
        specify { IndexedDocument.search_for(query, affiliates(:basic_affiliate), nil).should be_nil }
      end
    end

    context "when the query contains boolean operators" do
      before do
        IndexedDocument.destroy_all
        IndexedDocument.create!(@valid_attributes.merge(:title => 'boolean operator', :url => 'http://www.nps.gov/boolean.pdf', :content_hash => nil))
        IndexedDocument.create!(@valid_attributes.merge(:title => 'OR US97', :url => 'http://www.nps.gov/or_97.pdf', :content_hash => nil))
        IndexedDocument.create!(@valid_attributes.merge(:title => 'Newport city OR', :url => 'http://www.nps.gov/newport.pdf', :content_hash => nil))
        IndexedDocument.reindex
        Sunspot.commit
      end

      specify { IndexedDocument.search_for('++boolean ', affiliates(:basic_affiliate), nil).should_not be_nil }
      specify { IndexedDocument.search_for('OR US97', affiliates(:basic_affiliate), nil).should_not be_nil }
      specify { IndexedDocument.search_for('Newport OR', affiliates(:basic_affiliate), nil).should_not be_nil }
    end

    context 'when the query contains local params' do
      before do
        IndexedDocument.destroy_all
        IndexedDocument.create!(@valid_attributes.merge(:title => 'odie doc1', :url => 'http://www.nps.gov/odie_doc1.pdf', :content_hash => nil))
        IndexedDocument.create!(@valid_attributes.merge(:title => 'odie doc2', :url => 'http://www.nps.gov/odie_doc2.pdf', :content_hash => nil))
        IndexedDocument.create!(@valid_attributes.merge(:title => 'odie doc3', :url => 'http://www.nps.gov/odie_doc3.pdf', :content_hash => nil))
        IndexedDocument.reindex
        Sunspot.commit
      end

      specify { IndexedDocument.search_for('{!rows=3} odie', affiliates(:basic_affiliate), nil, 1, 1).hits.count.should == 1 }
    end

    context 'when filtering based on created_at' do
      before do
        IndexedDocument.destroy_all
        IndexedDocument.create!(@valid_attributes.merge(:title => 'old doc 8', :url => 'http://www.nps.gov/doc8.pdf',
                                                        :content_hash => nil, :created_at => 4.months.ago))
        IndexedDocument.create!(@valid_attributes.merge(:title => 'new doc 9', :url => 'http://www.nps.gov/doc9.pdf',
                                                        :content_hash => nil, :created_at => 1.weeks.ago))
        IndexedDocument.create!(@valid_attributes.merge(:title => 'new doc 10', :url => 'http://www.nps.gov/doc10.pdf',
                                                        :content_hash => nil, :created_at => 2.weeks.ago))
        IndexedDocument.reindex
        Sunspot.commit
      end

      it 'should return documents created after the specified date' do
        odie = IndexedDocument.search_for('doc', affiliates(:basic_affiliate), nil, 1, 3, Date.current.ago(3.months))
        titles = odie.results.collect(&:title)
        titles.should include('new doc 9')
        titles.should include('new doc 10')
        titles.should_not include('old doc 8')
      end
    end

    context "when .search raises an exception" do
      it "should return nil" do
        IndexedDocument.should_receive(:search).and_raise(RSolr::Error::Http.new({}, {}))
        IndexedDocument.search_for('tropicales', @affiliate, nil).should be_nil
      end
    end
  end

  describe "#fetch" do

    let(:indexed_document) { IndexedDocument.create!(@valid_attributes) }

    context "when the URL isn't a match for existing site domain entries for the affiliate" do
      before do
        indexed_document.affiliate.site_domains.destroy_all
        indexed_document.affiliate.site_domains.create!(:domain => "somethingelse.gov")
      end

      it "should delete the entry and stop processing" do
        indexed_document.should_receive(:remove_from_index)
        indexed_document.fetch
        IndexedDocument.exists?(indexed_document.id).should be_false
      end
    end

    it "should set the content hash for the entry" do
      indexed_document.should_receive(:index_document).with(kind_of(Tempfile), 'text/html')
      indexed_document.should_receive(:save_or_destroy)
      indexed_document.fetch
    end

    it "should set the load time attribute" do
      indexed_document.fetch
      indexed_document.reload
      indexed_document.load_time.should_not be_nil
    end

    context "when there is a problem fetching and indexing the URL content" do
      before do
        indexed_document.url = 'http://nps.gov/usasearch_test_301.shtml'
      end

      it "should update the url with last crawled date and error message and set the hash/title/body/description to nil" do
        indexed_document.fetch
        indexed_document.last_crawled_at.should_not be_nil
        indexed_document.last_crawl_status.should == "301 Moved Permanently"
        indexed_document.content_hash.should be_nil
        indexed_document.body.should be_nil
        indexed_document.title.should be_nil
        indexed_document.description.should be_nil
      end
    end

    context "when there is a problem updating the attributes after catching an exception during indexing" do
      before do
        Net::HTTP.stub!(:start).and_raise Exception.new("some problem during indexing")
        indexed_document.stub!(:update_attributes!).and_raise Timeout::Error
      end

      it "should handle the exception and delete the record" do
        indexed_document.fetch
        IndexedDocument.find_by_id(indexed_document.id).should be_nil
      end

      context "when there is a problem destroying the record" do
        before do
          indexed_document.stub!(:destroy).and_raise Exception.new("Some other problem")
        end

        it "should fail gracefully" do
          Rails.logger.should_receive(:warn)
          indexed_document.fetch
        end

      end
    end
  end

  describe "#save_or_destroy" do
    before do
      @indexed_document = IndexedDocument.create!(@valid_attributes)
    end

    context "when the content hash is a duplicate" do
      before do
        @indexed_document.stub!(:build_content_hash).and_return("foo")
        errors = mock(ActiveModel::Errors)
        errors.stub!(:full_messages).and_return ["Content hash is not unique: Identical content (title and body) already indexed"]
        @indexed_document.stub!(:errors).and_return errors
        @indexed_document.stub!(:save!).and_raise(ActiveRecord::RecordInvalid.new(@indexed_document))
      end

      it "should raise an IndexedDocumentError with the validation error as the message" do
        lambda { @indexed_document.save_or_destroy }.should raise_error(IndexedDocument::IndexedDocumentError, "Content hash is not unique: Identical content (title and body) already indexed")
      end
    end

    context "when Rails validation misses that it's a duplicate and MySQL throws an exception" do
      before do
        @indexed_document.stub!(:build_content_hash).and_return("foo")
        @indexed_document.stub!(:save!).and_raise(Mysql2::Error.new("oops"))
      end

      it "should catch the exception and delete the record" do
        @indexed_document.save_or_destroy
        IndexedDocument.find_by_id(@indexed_document.id).should be_nil
      end
    end
  end

  describe "#index_document(file, content_type)" do
    before do
      @indexed_document = IndexedDocument.create!(@min_valid_attributes)
      @file = open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm')
    end

    context "when the fetched document is a PDF doc" do
      before do
        @file.stub!(:content_type).and_return 'application/pdf'
      end

      it "should call index_application_file with 'pdf'" do
        @indexed_document.should_receive(:index_application_file).with(@file.path, 'pdf').and_return true
        @indexed_document.index_document(@file, @file.content_type)
      end
    end

    context "when the fetched document is a Word doc" do
      before do
        @file.stub!(:content_type).and_return 'application/msword'
      end

      it "should call index_application_file with 'word'" do
        @indexed_document.should_receive(:index_application_file).with(@file.path, 'word').and_return true
        @indexed_document.index_document(@file, @file.content_type)
      end
    end

    context "when the fetched document is a Powerpoint doc" do
      before do
        @file.stub!(:content_type).and_return 'application/ms-powerpoint'
      end

      it "should call index_application_file with 'ppt'" do
        @indexed_document.should_receive(:index_application_file).with(@file.path, 'ppt').and_return true
        @indexed_document.index_document(@file, @file.content_type)
      end
    end

    context "when the fetched document is an Excel doc" do
      before do
        @file.stub!(:content_type).and_return 'application/ms-excel'
      end

      it "should call index_application_file with 'excel'" do
        @indexed_document.should_receive(:index_application_file).with(@file.path, 'excel').and_return true
        @indexed_document.index_document(@file, @file.content_type)
      end
    end

    context "when the content type of the fetched document contains 'html'" do
      it "should call index_html" do
        @indexed_document.should_receive(:index_html).with(@file).and_return true
        @indexed_document.index_document(@file, 'text/html')
      end
    end

    context "when the content type of the fetched document is unknown" do
      before do
        @file.stub!(:content_type).and_return 'application/clipart'
      end

      it "should raise an IndexedDocumentError error indicating that the document type is not yet supported" do
        lambda { @indexed_document.index_document(@file, @file.content_type) }.should raise_error(IndexedDocument::IndexedDocumentError, "Unsupported document type: application/clipart")
      end
    end

    context "when the document is too big" do
      before do
        @file.stub!(:size).and_return IndexedDocument::MAX_DOC_SIZE+1
      end

      it "should raise an IndexedDocumentError error indicating that the document is too big" do
        lambda { @indexed_document.index_document(@file, @file.content_type) }.should raise_error(IndexedDocument::IndexedDocumentError, "Document is over 50mb limit")
      end
    end
  end

  describe "#index_html(file)" do
    context "when the page has a HTML title" do
      let(:indexed_document) { IndexedDocument.create!(@min_valid_attributes) }
      let(:file) { open(Rails.root.to_s + '/spec/fixtures/html/fresnel-lens-building-opens-july-23.htm') }

      context "when the title is long" do
        it "should use the title, truncated to 60 characters on a word boundary" do
          indexed_document.index_html(file)
          indexed_document.title.should == "Fire Island National Seashore - Fire Island Light Station..."
        end
      end

      it "should extract the text body from the document" do
        indexed_document.should_receive(:extract_body_from).and_return "this is the body"
        indexed_document.index_html open(Rails.root.to_s + '/spec/fixtures/html/data-layers.html')
        indexed_document.body.should == "this is the body"
      end

      it "should use a subset of the body as the description" do
        indexed_document.should_receive(:generate_generic_description).and_return "foo..."
        indexed_document.index_html open(Rails.root.to_s + '/spec/fixtures/html/data-layers.html')
        indexed_document.description.should == "foo..."
      end

      context "when the page body (inner text) is empty" do
        before do
          indexed_document.stub!(:scrub_inner_text)
        end

        it "should raise an IndexedDocumentError" do
          lambda { indexed_document.index_html(file) }.should raise_error(IndexedDocument::IndexedDocumentError)
        end
      end

      it "should try to find and index nested URLs" do
        indexed_document.should_receive(:discover_nested_docs).with(an_instance_of(Nokogiri::HTML::Document))
        indexed_document.index_html(file)
      end
    end
  end

  describe "#remove_common_substring(unescaped_substring)" do
    let(:indexed_document) { IndexedDocument.create!(:title => "some title", :body => "THIS IS GOOD TEXTSkip to Main Content Home FAQs SiteTHIS IS GOOD TEXT", :description => "THIS IS GOOD TEXTSkip to Main Content Home FAQs SiteTHIS IS GOOD TEXT", :last_crawl_status => 'OK', :url => "http://www.nps.gov/a.html", :affiliate => affiliates(:basic_affiliate)) }

    it "should remove the substring from the body and update the description" do
      indexed_document.remove_common_substring("Skip to Main Content Home FAQs Site")
      indexed_document.body.should=="THIS IS GOOD TEXT THIS IS GOOD TEXT"
      indexed_document.description.should=="THIS IS GOOD TEXT THIS IS GOOD TEXT"
    end

    context "when there is no body/description left after removing the template (e.g., 90% of the pages have different titles but duplicate descriptions)" do
      it "should just ignore the validation failure and move on (versus raising an exception)" do
        indexed_document.remove_common_substring("THIS IS GOOD TEXTSkip to Main Content Home FAQs SiteTHIS IS GOOD TEXT")
      end
    end
  end

  describe "#body_for_substring_detection" do
    context "when body length is under a threshold" do
      before do
        @indexed_document = IndexedDocument.new(:body => "something reasonable")
      end

      it "should return the body unchanged" do
        @indexed_document.body_for_substring_detection.should == @indexed_document.body
      end
    end

    context "when body length is over a threshold" do
      before do
        @header = 'a' * IndexedDocument::LARGE_DOCUMENT_SAMPLE_SIZE
        @footer = 'z' * IndexedDocument::LARGE_DOCUMENT_SAMPLE_SIZE
        content = 'q' * IndexedDocument::LARGE_DOCUMENT_SAMPLE_SIZE
        @indexed_document = IndexedDocument.new(:body => @header + content + @footer)
      end

      it "should return the leftmost part of the body concatenated with the rightmost part of the body" do
        @indexed_document.body_for_substring_detection.should == @header + @footer
      end
    end
  end

  describe "#extract_body_from(nokogiri_doc)" do
    let(:doc) { Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/usa_gov/audiences.html')) }
    let(:indexed_domain) { indexed_domains(:sample) }

    before do
      indexed_domain.common_substrings.create!(:substring => "Skip to Main Content Home FAQs Site Index E-mail Us Chat Get E-mail Updates Change Text Size Español Search 1 (800) FED-INFO|1 (800) 333-4636 Get Services Get It Done Online! Public Engagement Performance Dashboards Shop Government Auctions Replace Vital Records MORE SERVICES Government Jobs Change Your Address Explore Topics Jobs and Education Family, Home, and Community Public Safety and Law Health and Nutrition Travel and Recreation Money and Taxes Environment, Energy, and Agriculture Benefits and Grants Defense and International Consumer Guides Reference and General Government History, Arts, and Culture Voting and Elections Science and Technology Audiences Audiences Find Government Agencies All Government A-Z Index of the U.S. Government Federal Government Executive Branch Judicial Branch Legislative Branch State, Local, and Tribal State Government Local Government Tribal Government Contact Government U.S. Congress & White House Contact Government Elected Officials Agency Contacts Contact Us FAQs MORE CONTACTS Governor and State Legislators E-mail Print", :saturation => 99.9)
      indexed_domain.common_substrings.create!(:substring => "Connect with Government Facebook Twitter Mobile YouTube Our Blog Home About Us Contact Us Website Policies Privacy Suggest-A-Link Link to Us USA.gov is the U.S. government's official web portal.", :saturation => 99.9)
    end

    it "should return the inner text of the body of the document minus any common substrings" do
      indexed_document = IndexedDocument.new(:indexed_domain => indexed_domain, :url => "http://gov.nps.gov/page.html")
      body = indexed_document.extract_body_from(doc)
      body.should == "Share RSS You Are Here Home &gt; Citizens &gt; Especially for Specific Audiences Especially for Specific Audiences Removed the links here, too. This is the last page for the test, with dead ends on the breadcrumb, too Contact Your Government FAQs E-mail Us Chat Phone Page Last Reviewed or Updated: October 28, 2010"
    end
  end

  describe "#discover_nested_docs(doc)" do
    before do
      @aff = affiliates(:basic_affiliate)
      @aff.site_domains.destroy_all
      @aff.site_domains.create(:domain => "agency.gov")
      @indexed_document = IndexedDocument.new(:affiliate => @aff, :url => "http://www.agency.gov/index.html")
    end

    context "when the HTML document contains links" do
      before do
        @doc = Nokogiri::HTML(open(Rails.root.to_s + '/spec/fixtures/html/page_with_all_kinds_of_links.html'))
      end

      it "should create new IndexedDocuments with absolute URLs based on valid URLs with matching site domains" do
        @aff.indexed_documents.should_receive(:create).exactly(10).times
        @indexed_document.discover_nested_docs(@doc)
      end
    end

  end

  describe "#index_application_file(file)" do
    let(:indexed_document) { IndexedDocument.create!(@min_valid_attributes) }

    context "for a normal application file (PDF/Word/PPT/Excel)" do
      before do
        indexed_document.index_application_file(Rails.root.to_s + "/spec/fixtures/pdf/test.pdf", 'pdf')
      end

      it "should create an indexed document that has a title based on the title field and a description from the body text" do
        indexed_document.id.should_not be_nil
        indexed_document.title.should == "This is a test PDF file, we are use it to test our PDF parsing technology"
        indexed_document.description.should =~ /This is a test PDF file/
        indexed_document.description.should =~ /in the right.../
        indexed_document.url.should == @min_valid_attributes[:url]
      end

      it "should set the the time and status from the crawl" do
        indexed_document.last_crawled_at.should_not be_nil
        indexed_document.last_crawl_status.should == IndexedDocument::OK_STATUS
      end
    end

    context "for a PDF that, when parsed, has garbage characters in the description" do
      before do
        indexed_document.index_application_file(Rails.root.to_s + "/spec/fixtures/pdf/garbage_chars.pdf", 'pdf')
      end

      it "should remove the garbage characters from the description" do
        indexed_document.description.should_not =~ /[“’‘”]/
        indexed_document.description[0..-4].should_not =~ /[^\w_ ]/
        indexed_document.description.should_not =~ / /
      end
    end

    context "when the page content is empty" do
      before do
        indexed_document.stub!(:parse_file).and_return ""
      end

      it "should raise an IndexedDocumentError" do
        lambda { indexed_document.index_application_file(Rails.root.to_s + "/spec/fixtures/pdf/test.pdf", 'pdf') }.should raise_error(IndexedDocument::IndexedDocumentError)
      end
    end
  end

  describe "#extract_document_title(pdf_file_path, pdf_text)" do
    let(:indexed_document) { IndexedDocument.create!(@min_valid_attributes) }

    context "when title is defined" do
      before do
        indexed_document.stub!(:parse_file).and_return "title: some gov  document "
      end

      it "should return the title" do
        title = indexed_document.send(:extract_document_title, nil, "whatever")
        title.should == "some gov document"
      end
    end

    context "when title is an integer" do
      before do
        indexed_document.stub!(:parse_file).and_return "title: 1578"
      end

      it "should coerce the title into a string" do
        title = indexed_document.send(:extract_document_title, nil, "whatever")
        title.should == "1578"
      end
    end

    context "when title is a blank" do
      before do
        indexed_document.stub!(:parse_file).and_return "title:  "
      end

      it "should attempt to return the body text" do
        title = indexed_document.send(:extract_document_title, nil, "whatever")
        title.should == "whatever"
      end
    end

    context "when application document has no title" do
      before do
        indexed_document.stub!(:parse_file).and_return "Author: me\nDate: recently\n"
      end

      context "when body text contains no periods or newlines" do
        it "should return the cleaned body text" do
          title = indexed_document.send(:extract_document_title, nil, "CORRECTION: Obstructions listed for RUNWAY 30 represent an AV Obstruction Identification Surface")
          title.should == "CORRECTION: Obstructions listed for RUNWAY 30 represent an AV Obstruction Identification Surface"
        end
      end
    end
  end

  describe "#uncrawled_urls" do
    before do
      IndexedDocument.destroy_all
      @affiliate = affiliates(:basic_affiliate)
      @first_uncrawled_url = IndexedDocument.create!(:url => 'http://nps.gov/url1.html', :affiliate => @affiliate)
      @last_uncrawled_url = IndexedDocument.create!(:url => 'http://nps.gov/url2.html', :affiliate => @affiliate)
      affiliates(:power_affiliate).site_domains.create!(:domain => "anotheraffiliate.mil")
      @other_affiliate_uncrawled_url = IndexedDocument.create!(:url => 'http://anotheraffiliate.mil', :affiliate => affiliates(:power_affiliate))
      @already_crawled_url = IndexedDocument.create!(:url => 'http://nps.gov/uncrawled.html', :affiliate => @affiliate, :last_crawled_at => Time.now)
    end

    it "should return the first page of all crawled urls" do
      uncrawled_urls = IndexedDocument.uncrawled_urls(@affiliate)
      uncrawled_urls.size.should == 2
      uncrawled_urls.include?(@first_uncrawled_url).should be_true
      uncrawled_urls.include?(@last_uncrawled_url).should be_true
    end

    it "should paginate the results if the page is passed in" do
      uncrawled_urls = IndexedDocument.uncrawled_urls(@affiliate, 2)
      uncrawled_urls.should be_empty
    end
  end

  describe "#crawled_urls" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      @first_crawled_url = IndexedDocument.create!(:url => 'http://nps.gov/url1.html', :last_crawled_at => Time.now, :affiliate => @affiliate)
      @last_crawled_url = IndexedDocument.create!(:url => 'http://nps.gov/url2.html', :last_crawled_at => Time.now, :affiliate => @affiliate)
      affiliates(:power_affiliate).site_domains.create!(:domain => "anotheraffiliate.mil")
      IndexedDocument.create!(:url => 'http://anotheraffiliate.mil', :last_crawled_at => Time.now, :affiliate => affiliates(:power_affiliate))
    end

    it "should return the first page of all crawled urls" do
      crawled_urls = IndexedDocument.crawled_urls(@affiliate)
      crawled_urls.size.should == 2
      crawled_urls.include?(@first_crawled_url).should be_true
      crawled_urls.include?(@last_crawled_url).should be_true
    end

    it "should paginate the results if the page is passed in" do
      crawled_urls = IndexedDocument.crawled_urls(@affiliate, 2)
      crawled_urls.should be_empty
    end
  end

  describe "#process_file" do
    before do
      @affiliate = affiliates(:basic_affiliate)
    end

    context "when file format is not text/plain or txt" do
      before do
        @urls = %w(http://search.usa.gov http://nps.gov/url.html http://data.gov)
        tempfile = Tempfile.new('urls.xml')
        @urls.each do |url|
          tempfile.write(url + "\n")
        end
        tempfile.close
        tempfile.open
        @file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :type => 'text/xml')
      end

      it "should return with error_message" do
        IndexedDocument.process_file(@file, @affiliate).should == {:success => false, :error_message => 'Invalid file format; please upload a plain text file (.txt).'}
      end
    end

    context "when a file is passed in without any URLs" do
      before do
        tempfile = Tempfile.new('urls.txt')
        @file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :type => 'text/plain')
      end

      it "should return with success = false, and error message" do
        result = IndexedDocument.process_file(@file, @affiliate)
        result[:success].should be_false
        result[:error_message].should == 'No URLs uploaded; please check your file and try again.'
      end

      it "should not trigger a refresh on all the unfetched URLs for that affiliate" do
        @affiliate.should_not_receive(:refresh_indexed_documents)
      end
    end

    context "when a file is passed in with fewer than the maximum number of allowable URLs" do
      before do
        @urls = %w(http://nps.gov/url1.html http://nps.gov/url2.html http://nps.gov/url3.html)
        tempfile = Tempfile.new('urls.txt')
        @urls.each do |url|
          tempfile.write(url + "\n")
        end
        tempfile.close
        tempfile.open
        @file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :type => 'text/plain')
        @result = IndexedDocument.process_file(@file, @affiliate)
      end

      it "should create a new IndexedDocument for each of the lines in the file" do
        @urls.each { |url| IndexedDocument.find_by_url_and_affiliate_id(url, @affiliate.id).should_not be_nil }
      end

      it "should return with success = true, and count" do
        @result[:success].should be_true
        @result[:count].should == 3
      end
    end

    context "when a file is passed in with more than the limit of URLs" do
      before do
        tempfile = Tempfile.new('too_many_urls.txt')
        10001.times { |x| tempfile.write("http://nps.gov/#{x}\n") }
        tempfile.close
        tempfile.open
        @file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :type => 'text/plain')
        IndexedDocument.stub!(:create).and_return mock("idoc", :errors => [])
      end

      it "should return with success == false and error message if the number of URLs in the file exceeds MAX_URLS_PER_FILE_UPLOAD" do
        result = IndexedDocument.process_file(@file, @affiliate)
        result[:success].should be_false
        result[:error_message].should == 'Too many URLs in your file.  Please limit your file to 10000 URLs.'
      end

      it "should return with success == true if max_urls param is set above the number of URLs in the file" do
        result = IndexedDocument.process_file(@file, @affiliate, 100000)
        result[:success].should be_true
        result[:count].should == 10001
      end

      it "should return with success == true if '0' is passed as the number of maximum urls" do
        result = IndexedDocument.process_file(@file, @affiliate, 0)
        result[:success].should be_true
        result[:count].should == 10001
      end
    end

    context "when a file has at least one URL processed" do
      before do
        tempfile = Tempfile.new('urls.txt')
        %w(http://search.usa.gov/ http://nps.gov/uploaded.html http://data.gov/).each do |url|
          tempfile.write(url + "\n")
        end
        tempfile.close
        tempfile.open
        @file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :type => 'text/plain')
      end

      it "should trigger a refresh on all the unfetched URLs for that affiliate" do
        @affiliate.should_receive(:refresh_indexed_documents).with('unfetched')
        IndexedDocument.process_file(@file, @affiliate)
      end
    end
  end

  describe "#refresh(extent)" do
    before do
      IndexedDocument.destroy_all
      affiliates(:power_affiliate).site_domains.create!(:domain => "some.mil")
      IndexedDocument.create!(:url => 'http://some.mil/', :affiliate => affiliates(:power_affiliate))
      IndexedDocument.create!(:url => 'http://nps.gov', :affiliate => affiliates(:basic_affiliate))
    end

    context "when affiliates exist" do
      before do
        Affiliate.stub!(:find).and_return(affiliates(:power_affiliate), affiliates(:basic_affiliate))
      end

      it "should call refresh_indexed_documents(extent) on each affiliate that has indexed docs" do
        affiliates(:power_affiliate).should_receive(:refresh_indexed_documents).with('unfetched')
        affiliates(:basic_affiliate).should_receive(:refresh_indexed_documents).with('unfetched')
        IndexedDocument.refresh('unfetched')
      end
    end

    context "when affiliate has disappeared in the meanwhile" do
      before do
        Affiliate.stub!(:find).and_raise ActiveRecord::RecordNotFound
      end

      it "should ignore it and move on to the next affiliate" do
        IndexedDocument.refresh('unfetched')
      end
    end
  end

  describe "#bulk_load_urls" do
    before do
      IndexedDocument.destroy_all
      @file = Tempfile.new('aid_urls.txt')
      @aff = affiliates(:basic_affiliate)
      2.times { @file.puts([@aff.id, 'http://www.nps.gov/'].join("\t")) }
      @file.puts([@aff.id, 'http://www.usa.z/invalid'].join("\t"))
      @file.close
    end

    it "should create new, valid IndexedDocument entries" do
      IndexedDocument.bulk_load_urls(@file.path)
      IndexedDocument.count.should == 1
      IndexedDocument.find_by_url_and_affiliate_id("http://www.nps.gov/", @aff.id).should_not be_nil
    end

    it "should enqueue fetching and indexing content for these unfetched URLs" do
      IndexedDocument.should_receive(:refresh).with('unfetched')
      IndexedDocument.bulk_load_urls(@file.path)
    end

  end

  describe "#build_content_hash" do
    it "should build it from the title and body" do
      IndexedDocument.new(@valid_attributes).build_content_hash.should == 'c9046962bfec2648b59f3a4213b09bb4'
    end

    context "when title is empty" do
      it "should just use the body" do
        IndexedDocument.new(@valid_attributes.merge(:title => nil)).build_content_hash.should == '0a56786098d4b95f93ebff6070b0a24f'
      end
    end
  end

  describe "#normalize_error_message(e)" do
    context "when it's a timeout-related error" do
      it "should return 'Document took too long to fetch'" do
        indexed_document = IndexedDocument.new
        e = Exception.new('this is because execution expired')
        indexed_document.send(:normalize_error_message, e).should == 'Document took too long to fetch'
      end
    end

    context "when it's a protocol redirection-related error" do
      it "should return 'Redirection forbidden from HTTP to HTTPS'" do
        indexed_document = IndexedDocument.new
        e = Exception.new('redirection forbidden from this to that')
        indexed_document.send(:normalize_error_message, e).should == 'Redirection forbidden from HTTP to HTTPS'
      end
    end

    context "when it's an uncaught Mysql-related duplicate content error" do
      it "should return 'Content hash is not unique: Identical content (title and body) already indexed'" do
        indexed_document = IndexedDocument.new
        e = Exception.new('Mysql2::Error: Duplicate entry blah blah blah')
        indexed_document.send(:normalize_error_message, e).should == 'Content hash is not unique: Identical content (title and body) already indexed'
      end
    end

    context "when it's a generic error" do
      it "should return the error message" do
        indexed_document = IndexedDocument.new
        e = Exception.new('something awful happened')
        indexed_document.send(:normalize_error_message, e).should == 'something awful happened'
      end
    end
  end
end