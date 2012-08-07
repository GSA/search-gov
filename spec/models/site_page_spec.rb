# coding: utf-8
require 'spec_helper'

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
        es_site_index_doc = File.open(Rails.root.to_s + "/spec/fixtures/html/usa_gov/site_index_es.html")
        en_site_index_doc = File.open(Rails.root.to_s + "/spec/fixtures/html/usa_gov/site_index.html")
        agencies_doc = File.open(Rails.root.to_s + "/spec/fixtures/html/usa_gov/agencies.html")
        audiences_doc = File.open(Rails.root.to_s + "/spec/fixtures/html/usa_gov/audiences.html")
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
        fourth.breadcrumb.should == "<a href=\"http://m.gobiernousa.gov/\">Página principal</a> &gt; <a href=\"/usa/gobiernousa/Indice/A\">Índice del sitio</a> &gt; Índice del sitio"
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
        SitePage.stub!(:get_cookies).and_return "cookie"
        en_page_one = File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/1_en.html")
        en_faq = File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/faq_en.html")
        en_page_two = File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/2_en.html")
        es_page_one = File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/1_es.html")
        es_faq = File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/faq_es.html")
        es_page_two = File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/2_es.html")
        SitePage.stub!(:open).and_return(en_page_one, en_faq, en_page_two, en_faq, es_page_one, es_faq, es_page_two, es_faq)
      end

      it "should delete all existing answers, and crawl both English and Spanish sites" do
        SitePage.should_receive(:delete_all).with(["url_slug LIKE ?", "answers/%"])
        SitePage.should_receive(:delete_all).with(["url_slug LIKE ?", "respuestas/%"])
        SitePage.should_receive(:extract_featured_content).and_return('en_featured_content', 'es_featured_content')
        SitePage.crawl_answers_usa_gov
        SitePage.count.should == 8
        SitePage.all(:conditions => ['url_slug LIKE ?', 'answers/%']).count.should == 4
        SitePage.find_by_url_slug('answers/1').should_not be_nil
        SitePage.find_by_url_slug('answers/1').main_content.should match(%{<h1 class='answer-title'>Top Questions</h1>})
        SitePage.find_by_url_slug('answers/1').main_content.should match('en_featured_content')
        SitePage.find_by_url_slug('answers/1').main_content.should match('Next')
        SitePage.find_by_url_slug('answers/2').should_not be_nil
        SitePage.find_by_url_slug('answers/2').main_content.should match(%{<h1 class='answer-title'>Top Questions</h1>})
        SitePage.find_by_url_slug('answers/2').main_content.should match('Previous')
        SitePage.find_by_url_slug('answers/2').main_content.should_not match('en_featured_content')
        SitePage.find_by_url_slug('answers/3').should be_nil
        SitePage.all(:conditions => ['url_slug LIKE ?', 'respuestas/%']).count.should == 4
        SitePage.find_by_url_slug('respuestas/1').should_not be_nil
        SitePage.find_by_url_slug('respuestas/1').main_content.should match(%{<h1 class='answer-title'>RESPUESTAS MÁS POPULARES</h1>})
        SitePage.find_by_url_slug('respuestas/1').main_content.should match('es_featured_content')
        SitePage.find_by_url_slug('respuestas/1').main_content.should match('Siguiente')
        SitePage.find_by_url_slug('respuestas/2').should_not be_nil
        SitePage.find_by_url_slug('respuestas/2').main_content.should match(%{<h1 class='answer-title'>RESPUESTAS MÁS POPULARES</h1>})
        SitePage.find_by_url_slug('respuestas/2').main_content.should match('Anterior')
        SitePage.find_by_url_slug('respuestas/2').main_content.should_not match('es_featured_content')
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

  describe ".extract_featured_content" do
    let(:featured_content_index_en) { File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/featured_content_index_en.html") }
    let(:featured_content_item_1_en) { File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/featured_content_item_1_en.html") }
    let(:featured_content_item_2_en) { File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/featured_content_item_2_en.html") }
    let(:featured_content_index_es) { File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/featured_content_index_es.html") }
    let(:featured_content_item_1_es) { File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/featured_content_item_1_es.html") }
    let(:featured_content_item_2_es) { File.open(Rails.root.to_s + "/spec/fixtures/html/answers_usa_gov/featured_content_item_2_es.html") }
    let(:featured_content_beach_safety) { mock_model(SitePage, { :title => 'Beach Safety', :url_slug => 'answers/beach-safety', :main_content => 'beach_safety_content' }) }
    let(:featured_content_earthquake) { mock_model(SitePage, { :title => 'Earthquake in the Northeastern U.S.', :url_slug => 'answers/earthquake-in-the-northeastern-u-s', :main_content => 'earthquake_content' }) }
    let(:featured_content_asesoramiento) { mock_model(SitePage, { :title => 'Asesoramiento en temas de vivienda', :url_slug => 'respuestas/asesoramiento-en-temas-de-vivienda', :main_content => 'asesoramiento_content' }) }
    let(:featured_content_ayuda) { mock_model(SitePage, { :title => 'Ayuda con la hipoteca', :url_slug => 'respuestas/ayuda-con-la-hipoteca', :main_content => 'ayuda_content' }) }

    describe "for English pages" do
      before do
        SitePage.should_receive(:find_or_initialize_by_url_slug).with('answers/beach-safety').and_return(featured_content_beach_safety)
        SitePage.should_receive(:find_or_initialize_by_url_slug).with('answers/earthquake-in-the-northeastern-u-s').and_return(featured_content_earthquake)
        featured_content_beach_safety.should_receive(:update_attributes!)
        featured_content_earthquake.should_receive(:update_attributes!)
      end

      it "should retrieve featured content" do
        SitePage.stub!(:open).and_return(featured_content_index_en, featured_content_item_1_en, featured_content_item_2_en)
        featured_content_index_page = SitePage.extract_featured_content({ 'Cookie' => 'cookie' }, 'en')
        featured_content_index_page.should match(%{<h1 class='answer-title'>Featured Content</h1>})
        featured_content_index_page.should match(%{<a href='/usa/#{featured_content_beach_safety.url_slug}'>#{featured_content_beach_safety.title}</a>})
        featured_content_index_page.should match(%{<a href='/usa/#{featured_content_earthquake.url_slug}'>#{featured_content_earthquake.title}</a>})
      end
    end

    describe "for Spanish pages" do
      before do
        SitePage.should_receive(:find_or_initialize_by_url_slug).with('respuestas/asesoramiento-en-temas-de-vivienda').and_return(featured_content_asesoramiento)
        SitePage.should_receive(:find_or_initialize_by_url_slug).with('respuestas/ayuda-con-la-hipoteca').and_return(featured_content_ayuda)
        featured_content_asesoramiento.should_receive(:update_attributes!)
        featured_content_ayuda.should_receive(:update_attributes!)
        SitePage.stub!(:open).and_return(featured_content_index_es, featured_content_item_1_es, featured_content_item_2_es)
      end

      it "should retrieve Spanish featured content" do
        featured_content_index_page = SitePage.extract_featured_content({ 'Cookie' => 'cookie' }, 'es')
        featured_content_index_page.should match(%{<h1 class='answer-title'>LO MÁS DESTACADO</h1>})
        featured_content_index_page.should match(%{<a href='/usa/#{featured_content_asesoramiento.url_slug}'>#{featured_content_asesoramiento.title}</a>})
        featured_content_index_page.should match(%{<a href='/usa/#{featured_content_ayuda.url_slug}'>#{featured_content_ayuda.title}</a>})
      end
    end

    describe "when an error in opening featured content index page" do
      before do
        SitePage.should_receive(:open).and_throw(:exception)
        Rails.logger.should_receive(:error).once.with(%r{Trouble fetching http://respuestas.gobiernousa.gov/})
      end

      it "should return blank" do
        SitePage.extract_featured_content({ 'Cookie' => 'cookie' }, 'es').should be_blank
      end
    end

    describe "when an error occurs in extracting a faq page" do
      before do
        SitePage.should_receive(:open).ordered.and_return(featured_content_index_en)
        SitePage.should_receive(:open).twice.ordered.and_throw(:exception)
        Rails.logger.should_receive(:error).twice
      end

      it "should return blank" do
        SitePage.extract_featured_content({ 'Cookie' => 'cookie' }, 'en').should be_blank
      end
    end
  end
end
