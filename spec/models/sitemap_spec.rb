require 'spec_helper'

describe Sitemap do
  fixtures :affiliates, :features

  before do
    affiliates(:power_affiliate).site_domains.create!(:domain => 'example.gov')
    @valid_attributes = {
      :url => 'http://www.example.gov/sitemap.xml',
      :affiliate_id => affiliates(:power_affiliate).id
    }
  end

  context "when creating a new Sitemap" do
    context "when the URL points to a valid sitemap" do
      before do
        sitemap = File.open(Rails.root.to_s + '/spec/fixtures/xml/sitemap.xml')
        Kernel.stub!(:open).and_return sitemap
        Sitemap.create!(@valid_attributes)
      end

      it { should validate_presence_of :url }
      it { should validate_uniqueness_of(:url).scoped_to(:affiliate_id) }
      it { should belong_to(:affiliate) }
    end

    context "when the URL points to an invalid sitemap" do
      before do
        sitemap = File.open(Rails.root.to_s + "/spec/fixtures/rss/wh_blog.xml")
        Kernel.stub!(:open).and_return sitemap
      end

      it "should generate errors stating the sitemap is invalid" do
        sitemap = Sitemap.create(@valid_attributes)
        sitemap.errors.should_not be_empty
        sitemap.errors.first.last.should == "The Sitemap URL specified does not appear to be a valid Sitemap."
      end
    end

    context "when there is some error in crawling the sitemap" do
      before do
        Kernel.stub!(:open).and_raise "Some error!"
      end

      it "should pass on the error information in the error message" do
        sitemap = Sitemap.create(@valid_attributes)
        sitemap.errors.should_not be_empty
        sitemap.errors.first.last.should == "The Sitemap URL specified does not appear to be a valid Sitemap.  Additional information: Some error!"
      end
    end
  end

  describe "#fetch" do
    before do
      File.stub!(:delete)
      @sitemap = Sitemap.new(@valid_attributes)
      @sitemap.stub!(:is_valid_sitemap?).and_return true
    end

    context "when there is a problem fetching the URL content" do
      before do
        @sitemap.stub!(:open).and_raise Exception.new("404 Document Not Found")
      end

      it "should log the error" do
        Rails.logger.should_receive(:warn)
        @sitemap.fetch
      end
    end

    context "when the URL points to a valid sitemap" do
      before do
        @sitemap_io = open(Rails.root.to_s + '/spec/fixtures/xml/sitemap.xml')
        @sitemap.stub!(:open).and_return @sitemap_io
      end

      it "should update the url with last crawled date and error message" do
        @sitemap.fetch
        @sitemap.last_crawled_at.should_not be_nil
      end

      it "should call parse" do
        @sitemap.should_receive(:parse).with(@sitemap_io)
        @sitemap.fetch
      end

    end
  end

  describe "#parse(file)" do
    before do
      @sitemap = Sitemap.new(@valid_attributes)
      @sitemap.stub!(:is_valid_sitemap?).and_return true
      @sitemap.affiliate.features << features(:hosted_sitemaps)
      BingSearch.stub(:search_for_url_in_bing).and_return(nil)
    end

    context "when the sitemap is a valid sitemap" do
      before do
        @file = open(Rails.root.to_s + '/spec/fixtures/xml/sitemap.xml')
      end

      context "when the sitemap has never been seen before" do
        before do
          @sitemap.parse(@file)
        end

        it "should create IndexedDocuments for the affiliate for each entry in the sitemap" do
          @sitemap.affiliate.indexed_documents.size.should == 1
          @sitemap.affiliate.indexed_documents.first.url.should == "http://www.example.gov/"
        end
      end

      context "when the sitemap has been parsed before" do
        before do
          IndexedDocument.create!(:url => "http://www.example.gov/", :affiliate => @sitemap.affiliate)
          @sitemap.affiliate.indexed_documents.size.should == 1
          @sitemap.parse(@file)
        end

        it "should ignore urls that are already known" do
          @sitemap.affiliate.indexed_documents.size.should == 1
        end
      end
    end

    context "when the sitemap is a valid sitemap index" do
      before do
        @file = open(Rails.root.to_s + '/spec/fixtures/xml/sitemapindex.xml')
      end

      it "should create sitemaps for each sitemap listed in the index" do
        Sitemap.should_receive(:create).exactly(3).times
        @sitemap.parse(@file)
      end
    end
  end

  describe "#refresh" do
    before do
      Sitemap.delete_all
      sitemap = File.open(Rails.root.to_s + '/spec/fixtures/xml/sitemap.xml')
      Kernel.stub!(:open).and_return sitemap
      Sitemap.create!(@valid_attributes)
    end

    it "should enqueue fetching of all sitemaps" do
      Sitemap.all.each { |sitemap| Resque.should_receive(:enqueue_with_priority).with(:low, SitemapFetcher, sitemap.id) }
      Sitemap.refresh
    end
  end
end
