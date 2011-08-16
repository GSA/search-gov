require 'spec/spec_helper'

describe SitePage do
  fixtures :site_pages

  describe "Creating new instance" do
    it { should validate_uniqueness_of :url_slug }
    it { should validate_presence_of :url_slug }

    it "should create a new instance given valid attributes" do
      SitePage.create!(:url_slug => "slug", :title=> "title", :breadcrumb => "breadcrumb", :main_content => "main_content")
    end
  end

  describe "#crawl_usa_gov" do
    context "when crawling" do
      before do
        es_site_index_doc = Hpricot(File.open(Rails.root.to_s + "/spec/fixtures/html/usa_gov/site_index_es.html"))
        en_site_index_doc = Hpricot(File.open(Rails.root.to_s + "/spec/fixtures/html/usa_gov/site_index.html"))
        agencies_doc = Hpricot(File.open(Rails.root.to_s + "/spec/fixtures/html/usa_gov/agencies.html"))
        audiences_doc = Hpricot(File.open(Rails.root.to_s + "/spec/fixtures/html/usa_gov/audiences.html"))
        SitePage.should_receive(:open).and_return(es_site_index_doc, en_site_index_doc, agencies_doc, audiences_doc)
      end

      it "should generate SitePages from the USA.gov website" do
        SitePage.crawl_usa_gov
        SitePage.count.should == 4
        first = SitePage.find_by_url_slug "site_index"
        first.title.should == "Site Index"
        first.breadcrumb.should == "<a href=\"/\">Home</a> &gt; Site Index"
        first.main_content.should match(/^<h1 id.*<\/span> <\/li> <\/ul> <\/div> $/)
        second = SitePage.find_by_url_slug "Agencies/Federal/All_Agencies/index"
        second.title.should == "A-Z Index of U.S. Government Departments and Agencies"
        second.breadcrumb.should == "<a href=\"/\">Home</a> &gt; <a href=\"/usa/Topics/Audiences \">A-Z Index with a whitespace at the end</a> &gt; A-Z Index of U.S. Government Departments and Agencies"
        second.main_content.should match(/^<h1 id.*make sure the crawler follows the breadcrumb links.*<\/script>$/)
        third = SitePage.find_by_url_slug "Topics/Audiences"
        third.title.should == "Especially for Specific Audiences"
        third.breadcrumb.should == "<a href=\"/\">Home</a> &gt; <a href=\"/\">Citizens</a> &gt; Especially for Specific Audiences"
        third.main_content.should match(/^<h1 id.*dead ends on the breadcrumb.*<\/script>$/)
        fourth = SitePage.find_by_url_slug "gobiernousa/Indice/A"
        fourth.title.should == "Índice del sitio"
        fourth.breadcrumb.should == "<a href=\"/?locale=es\">Página principal</a> &gt; <a href=\"/usa/gobiernousa/Indice/A\">Índice del sitio</a> &gt; Índice del sitio"
        fourth.main_content.should match(/^<h1 id.*Just here to show that we're crawling Spanish pages, too.*$/)
      end

      context "when prior site pages exist" do
        before do
          SitePage.create!(:url_slug => "old slug", :title=> "old title", :breadcrumb => "old breadcrumb", :main_content => "old content")
        end

        it "should delete any prior site pages" do
          SitePage.crawl_usa_gov
          SitePage.exists?(:url_slug => "old slug", :title=> "old title", :breadcrumb => "old breadcrumb", :main_content => "old content").should be_false
        end
      end
    end

    context "when some usa.gov links point to non-existent/broken pages" do
      before do
        SitePage.stub!(:open).and_raise(Exception)
      end

      it "should log the error and continue" do
        Rails.logger.should_receive(:error).twice
        SitePage.crawl_usa_gov
      end
    end
  end

  describe "#crawl_answers_usa_gov" do
    context "when crawling" do
      before do
        SitePage.delete_all
        en_page_one = Hpricot(File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/1_en.html"))
        en_faq = Hpricot(File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/faq_en.html"))
        en_page_two = Hpricot(File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/2_en.html"))
        es_page_one = Hpricot(File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/1_es.html"))
        es_faq = Hpricot(File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/faq_es.html"))
        es_page_two = Hpricot(File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/2_es.html"))
        SitePage.stub!(:open).and_return(en_page_one, en_faq, en_page_two, en_faq, es_page_one, es_faq, es_page_two, es_faq)
      end

      it "should delete all existing answers, and crawl both English and Spanish sites" do
        SitePage.should_receive(:delete_all).with(["url_slug LIKE ?", "answers/%"])
        SitePage.should_receive(:delete_all).with(["url_slug LIKE ?", "respuestas/%"])
        SitePage.crawl_answers_usa_gov
        SitePage.count.should == 8
        SitePage.all(:conditions => ['url_slug LIKE ?', 'answers/%']).count.should == 4
        SitePage.find_by_url_slug('answers/1').should_not be_nil
        SitePage.find_by_url_slug('answers/2').should_not be_nil
        SitePage.find_by_url_slug('answers/3').should be_nil
        SitePage.all(:conditions => ['url_slug LIKE ?', 'respuestas/%']).count.should == 4
        SitePage.find_by_url_slug('respuestas/1').should_not be_nil
        SitePage.find_by_url_slug('respuestas/2').should_not be_nil
        SitePage.find_by_url_slug('respuestas/3').should be_nil
      end
    end

    context "when an error occurs crawling" do
      before do
        SitePage.stub!(:open).and_raise(Exception)
      end

      it "should log the error" do
        Rails.logger.should_receive(:error).twice
        SitePage.crawl_answers_usa_gov
      end
    end
  end
end