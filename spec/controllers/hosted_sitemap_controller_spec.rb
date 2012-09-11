require 'spec_helper'

describe HostedSitemapController, "#show" do
  it "should set the request fomat to :xml" do
    get :show, :id => "3"
    response.content_type.should == 'application/xml'
  end

  context "when the indexed domain can't be found" do
    it "should not assign @indexed_documents" do
      get :show, :id => "314159"
      assigns[:indexed_documents].should be_nil
    end
  end

  context "when the indexed domain is available" do
    fixtures :affiliates, :features
    render_views
    before do
      @domain = "www.govdotgov.gov"
      affiliate = affiliates(:power_affiliate)
      affiliate.features << features(:hosted_sitemaps)
      @indexed_domain = affiliate.indexed_domains.create!(:domain => @domain)
      affiliate.site_domains.create!(:domain => @domain)
      affiliate.site_domains.create!(:domain => 'honeybadger.gov')
      @indexed_domain.indexed_documents.create!(:affiliate => affiliate, :url => "http://#{@domain}/foo.html", :last_crawl_status=>"OK", :title => "foo", :description => "bar")
      @indexed_domain.indexed_documents.create!(:affiliate => affiliate, :url => "http://#{@domain}/bar.html", :last_crawl_status=>"OK", :title => "foo", :description => "bar")
      @indexed_domain.indexed_documents.create!(:affiliate => affiliate, :url => "http://#{@domain}/blat.html", :last_crawl_status=>"OK", :title => "foo", :description => "bar")
      @indexed_domain.indexed_documents.create!(:affiliate => affiliate, :url => "http://#{@domain}/dupe.html", :last_crawl_status=>"dupe", :title => "foo dupe", :description => "bar dupe")
      @indexed_domain.indexed_documents.create!(:affiliate => affiliate, :url => "http://www.honeybadger.gov/ignoreme.html", :last_crawl_status=>"OK", :title => "foo", :description => "bar")
    end

    context "when there are too many indexed documents for the domain to fit in a single sitemap file" do
      before do
        @controller.stub!(:max_urls_per_sitemap).and_return 2
      end

      context "when a valid page parameter is specified" do
        it "should return an individual sitemap file for that page of OK indexed document URLs" do
          get :show, :id => @indexed_domain.id.to_s, :page => "1"
          doc = Hpricot.XML(response.body.to_s)
          (doc/:urlset/:url).size.should == 2
          get :show, :id => @indexed_domain.id.to_s, :page => "2"
          doc = Hpricot.XML(response.body.to_s)
          (doc/:urlset/:url).size.should == 1
        end
      end

      context "when an invalid page parameter is specified" do
        it "should return an individual sitemap file for the first page of indexed document URLs" do
          get :show, :id => @indexed_domain.id.to_s, :page => "0"
          doc = Hpricot.XML(response.body.to_s)
          (doc/:urlset/:url).size.should == 2
        end
      end

      context "when no page parameter is specified" do
        it "should return a sitemap index file" do
          get :show, :id => @indexed_domain.id.to_s
          doc = Hpricot.XML(response.body.to_s)
          (doc/:sitemapindex/:sitemap).size.should == 2
          urls = (doc/:sitemapindex/:sitemap/:loc).collect(&:inner_html)
          urls.should include("http://test.host/usasearch_hosted_sitemap/#{@indexed_domain.id}.xml?page=1")
          urls.should include("http://test.host/usasearch_hosted_sitemap/#{@indexed_domain.id}.xml?page=2")
        end
      end
    end

    context "when the indexed documents for the domain can fit in a single sitemap file" do
      it "should return a valid sitemap with all OK urls for that domain" do
        get :show, :id => @indexed_domain.id.to_s
        doc = Hpricot.XML(response.body.to_s)
        (doc/:urlset/:url).size.should == 3
        urls = (doc/:urlset/:url/:loc).collect(&:inner_html)
        urls.should include("http://#{@domain}/bar.html")
        urls.should include("http://#{@domain}/blat.html")
        urls.should include("http://#{@domain}/foo.html")
      end
    end
  end
end