# coding: utf-8
require 'spec_helper'
require 'ostruct'

describe SearchHelper do
  fixtures :affiliates
  before do
    @affiliate = affiliates(:usagov_affiliate)
  end

  describe "#no_news_results_for(search)" do
    let(:search) { NewsSearch.new(:query => '<XSS>', :tbs => "w", :affiliate => affiliates(:basic_affiliate)) }

    it "should HTML escape the query string" do
      expect(helper.no_news_results_for(search)).to include("&lt;XSS&gt;")
    end
  end

  describe "#display_bing_result_extname_prefix" do
    before do
      @urls_that_need_a_box = []
      %w{http ftp}.each do |protocol|
        ["www.irs.gov", "www2.offthemap.nasa.gov"].each do |host|
          ["", ":8080"].each do |port|
            %w{doc.pdf README.TXT readme.txt ~root/Resume.doc showme.pdf showme.pdf?include=all some/longer/path.pdf}.each do |path|
              @urls_that_need_a_box << "#{protocol}://#{host}#{port}/#{path}"
            end
          end
        end
      end
      @urls_that_dont_need_a_box = @urls_that_need_a_box.collect { |url| url.gsub(".pdf", ".html").gsub(".PDF", ".HTM").gsub(".doc", ".html").gsub(".TXT", ".HTML").gsub(".txt", ".html") }
      @urls_that_dont_need_a_box << ":"
      @urls_that_dont_need_a_box << "https://www.usa.gov/"
      @urls_that_dont_need_a_box << "https://www.usa.gov/faq"
      @urls_that_dont_need_a_box << "https://www.usa.gov/faq?q=meaning+of+life"
    end

    it "should return empty string for most types of URLs" do
      @urls_that_dont_need_a_box.each do |url|
        expect(helper.display_web_result_extname_prefix({'unescapedUrl' => url})).to eq("")
      end
    end

    it "should return [TYP] span for some URLs" do
      @urls_that_need_a_box.each do |url|
        path_extname = url.gsub(/.*\//, "").gsub(/\?.*/, "").gsub(/[a-zA-Z0-9_]+\./, "").upcase
        prefix = "<span class=\"uext_type\">[#{path_extname.upcase}]</span> "
        expect(helper.display_web_result_extname_prefix({'unescapedUrl' => url})).to eq(prefix)
      end
    end
  end

  describe "#thumbnail_image_tag" do
    before do
      @image_result = {
        "FileSize" => 2555475,
        "Thumbnail" => {
          "FileSize" => 3728,
          "Url" => "http://ts1.mm.bing.net/images/thumbnail.aspx?q=327984100492&id=22f3cf1f7970509592422738e08108b1",
          "Width" => 160,
          "Height" => 120,
          "ContentType" => "image/jpeg"
        },
        "title" => " ... Inauguration of Barack Obama",
        "MediaUrl" => "http://www.house.gov/list/speech/mi01_stupak/morenews/Obama.JPG",
        "Url" => "http://www.house.gov/list/speech/mi01_stupak/morenews/20090120inauguration.html",
        "DisplayUrl" => "http://www.house.gov/list/speech/mi01_stupak/morenews/20090120inauguration.html",
        "Width" => 3264,
        "Height" => 2448,
        "ContentType" => "image/jpeg"
      }
    end

    context "for popular images" do
      it "should create an image tag that respects max height and max width when present" do
        expect(helper.send(:thumbnail_image_tag, @image_result, 80, 100)).to match(/width="80"/)
        expect(helper.send(:thumbnail_image_tag, @image_result, 80, 100)).to match(/height="60"/)

        expect(helper.send(:thumbnail_image_tag, @image_result, 150, 90)).to match(/width="120"/)
        expect(helper.send(:thumbnail_image_tag, @image_result, 150, 90)).to match(/height="90"/)
      end
    end

    context "for image search results" do
      it "should return an image tag with thumbnail height and width" do
        expect(helper.send(:thumbnail_image_tag, @image_result)).to match(/width="160"/)
        expect(helper.send(:thumbnail_image_tag, @image_result)).to match(/height="120"/)
      end
    end
  end
  
  describe "#display_image_result_link" do
    before do
      @result = {'Url' => 'http://aHost.gov/aPath',
                 'title' => 'aTitle',
                 'Thumbnail' => {'Url' => 'thumbnail.png', 'Width' => 40, 'Height' => 30},
                 'MediaUrl' => 'aMediaUrl'}
      @query = "NASA's"
      @affiliate = double('affiliate', :name => 'special affiliate name')
      @search = double('search', {query: @query, queried_at_seconds: Time.now.to_i, spelling_suggestion: nil, module_tag: 'BOGUS_MODULE'})
      @index = 100
      @onmousedown_attr = 'onmousedown attribute'
    end

    it "should generate onmousedown with affiliate name" do
      expect(helper).to receive(:onmousedown_attribute_for_image_click).
        with(@query, @result['Url'], @index, @affiliate.name, 'BOGUS_MODULE', @search.queried_at_seconds, :image).
        and_return(@onmousedown_attr)
      helper.display_image_result_link(@result, @search, @affiliate, @index, :image)
    end

    it "should generate onmousedown with blank affiliate name if affiliate is nil" do
      expect(helper).to receive(:onmousedown_attribute_for_image_click).
        with(@query, @result['Url'], @index, "", 'BOGUS_MODULE', @search.queried_at_seconds, :image).
        and_return(@onmousedown_attr)
      helper.display_image_result_link(@result, @search, nil, @index, :image)
    end

    it "should contain tracked links" do
      expect(helper).to receive(:onmousedown_attribute_for_image_click).
        with(@query, @result['Url'], @index, @affiliate.name, 'BOGUS_MODULE', @search.queried_at_seconds, :image).
        and_return(@onmousedown_attr)
      expect(helper).to receive(:tracked_click_thumbnail_image_link).with(@result, @onmousedown_attr, nil, nil).and_return("thumbnail_image_link_content")
      expect(helper).to receive(:tracked_click_thumbnail_link).with(@result, @onmousedown_attr).and_return("thumbnail_link_content")

      content = helper.display_image_result_link(@result, @search, @affiliate, @index, :image)

      expect(content).to have_content("thumbnail_image_link_content")
      expect(content).to have_content("thumbnail_link_content")
    end

    it "should use spelling suggestion as the query if one exists" do
      @search = double('search', {query: 'satalate', queried_at_seconds: Time.now.to_i, spelling_suggestion: 'satellite', module_tag: 'BOGUS_MODULE'})
      expect(helper).to receive(:onmousedown_attribute_for_image_click).
        with("satellite", @result['Url'], @index, @affiliate.name, 'BOGUS_MODULE', @search.queried_at_seconds, :image).
        and_return(@onmousedown_attr)
      helper.display_image_result_link(@result, @search, @affiliate, @index, :image)
    end
  end

  describe "#tracked_click_thumbnail_image_link" do
    before do
      @result = { 'Url' => 'aUrl', 'title' => 'aTitle', 'Thumbnail' => {
        'Url' => 'thumbnail.png',
        'Width' => 40,
        'Height' => 30
      } }
      @onmousedown_attr = "onmousedown_attribute"
    end

    it "should return a link to the result url" do
      content = helper.tracked_click_thumbnail_image_link(@result, @onmousedown_attr)
      expect(content).to have_selector("a[href='aUrl'][onmousedown='#{@onmousedown_attr}']")
    end
  end

  describe "#tracked_click_thumbnail_link" do
    before do
      @result = { 'Url' => 'http://aHost.gov/aPath',
                  'title' => 'aTitle',
                  'Thumbnail' => { 'Url' => 'aThumbnailUrl', 'Width' => 40, 'Height' => 30 } }
      @onmousedown_attr = "onmousedown_attribute"
    end

    it "should be a link to the result thumbnail url" do
      content = helper.tracked_click_thumbnail_link(@result, @onmousedown_attr)
      expect(content).to have_selector("a[href='http://aHost.gov/aPath'][onmousedown='#{@onmousedown_attr}']", text: 'aHost.gov')
    end
  end

  describe "#onmousedown_attribute_for_image_click" do
    it "should return with escaped query parameter and (index + 1) value" do
      now = Time.now.to_i
      content = helper.onmousedown_attribute_for_image_click("NASA's Space Rock", "url", 99, "affiliate name", "SOURCE", now, :image)
      expect(content).to eq("return clk('NASA\\&#39;s Space Rock', 'url', 100, 'affiliate name', 'SOURCE', #{now}, 'image', 'en')")
    end
  end

  describe "#tracked_click_link" do
    it "should track spelling suggestion as the query if one exists" do
      search = double('search', {:query => 'satalite', :queried_at_seconds => Time.now.to_i, :spelling_suggestion => 'satellite'})
      expect(helper).to receive(:onmousedown_for_click).with(search.spelling_suggestion, 100, '', 'BWEB', search.queried_at_seconds, :image)
      helper.tracked_click_link("aUrl", "aTitle", search, nil, 100, 'BWEB', :image)
    end

    it "should track query if spelling suggestion does not exist" do
      search = double('search', {:query => 'satalite', :queried_at_seconds => Time.now.to_i, :spelling_suggestion => nil})
      expect(helper).to receive(:onmousedown_for_click).with(search.query, 100, '', 'BWEB', search.queried_at_seconds, :image)
      helper.tracked_click_link("aUrl", "aTitle", search, nil, 100, 'BWEB', :image)
    end
  end

  describe "#display_result_description" do
    it 'should be html safe' do
      description = <<-DESCRIPTION
loren & david's excellent™ html "examples" on the <i>tag</i> and <b> too. loren & david's excellent™ html "examples" on the <i>tag</i> and <b> too. loren & david's excellent™ html "examples" on the <i>tag</i> and <b> too. loren & david's excellent™ html truncate me if you want
      DESCRIPTION

      search = {'content' => description}
      result = helper.display_result_description(search)
      expect(result).to be_html_safe
      expect(result).to eq("<strong>loren</strong> &amp; david's excellent™ html \"examples\" on the &lt;i&gt;tag&lt;/i&gt; and &lt;b&gt; too. <strong>loren</strong> &amp; david's excellent™ html \"examples\" on the &lt;i&gt;tag&lt;/i&gt; and &lt;b&gt; too. <strong>lo</strong> ...")
    end

    it 'should truncate long description' do
      description = <<-DESCRIPTION
The Vietnam War Memorial National Mall Washington, D.C. 2:27 P.M. EDT THE PRESIDENT:  Good afternoon, everybody.
Chuck, thank you for your words and your friendship and your life of service.
Veterans of the Vietnam War, families, friends, distinguished guests. I know it is hot.
      DESCRIPTION
      truncated_description = helper.display_result_description({'content' => description})
      expect(truncated_description).to match(/and \.\.\.$/)
      expect(truncated_description.length).to be <= 153
    end
  end

  describe "#display_search_all_affiliate_sites_suggestion" do
    context "when affiliate is present and matching_site_limits is blank" do
      let(:search) { double('search') }

      before do
        expect(search).to receive(:matching_site_limits).and_return(nil)
      end

      specify { expect(helper.display_search_all_affiliate_sites_suggestion(search)).to be_blank }
    end

    context "when affiliate is present and matching_site_limits is present" do
      let(:search) { double('search', :query => 'Yosemite', :site_limits => 'WWW1.NPS.GOV') }

      it "should display a link to 'Yosemite from all sites'" do
        expect(search).to receive(:matching_site_limits).exactly(3).times.and_return(['WWW1.NPS.GOV'])
        expect(helper).to receive(:search_path).with(hash_not_including(:sitelimit)).and_return('search_path_with_params')
        content = helper.display_search_all_affiliate_sites_suggestion(search)
        expect(content).to match /#{Regexp.escape("We're including results for 'Yosemite' from only WWW1.NPS.GOV.")}/
        expect(content).to have_selector("a[href='search_path_with_params']", text: "'Yosemite' from all sites")
        expect(content).to be_html_safe
      end
    end
  end

  describe "#translate_bing_highlights" do
    let(:body_with_regex_special_character) { "\uE000[Mil\uE001 .gov" }

    specify { expect(helper.translate_bing_highlights(body_with_regex_special_character)).to eq("<strong>[Mil</strong> .gov") }
  end

  describe '#make_summary_p' do
    context 'when locale = :en' do
      it "should return 'Page %{page} of about %{total} results' when total >= 100 and page > 1" do
        search = double(Search, :total => 2000, :page => 5, :first_page? => false)
        expect(make_summary_p(search)).to eq('<p>Page 5 of about 2,000 results</p>')
      end
    end

    context 'when locale = :es' do
      before(:all) { I18n.locale = :es }

      it "should return '1 resultado' when total = 1" do
        search = double(Search, :total => 1, :first_page? => true)
        expect(make_summary_p(search)).to eq('<p>1 resultado</p>')
      end

      it "should return 'Página %{page} de %{total} resultados' when total is 2..99 and page > 1" do
        search = double(Search, :total => 80, :page => 5, :first_page? => false)
        expect(make_summary_p(search)).to eq('<p>Página 5 de 80 resultados</p>')
      end

      it "should return 'Página %{page} de aproximadamente %{total} resultados' when total >= 100 and page > 1" do
        search = double(Search, :total => 2000, :page => 5, :first_page? => false)
        expect(make_summary_p(search)).to eq('<p>Página 5 de aproximadamente 2,000 resultados</p>')
      end

      after(:all) { I18n.locale = I18n.default_locale }
    end
  end

  describe '#search_results_by_logo(module_tag)' do
    context 'when locale is en' do
      before(:all) { I18n.locale = :en }
      after(:all) { I18n.locale = I18n.default_locale }

      context 'when results by Azure/Bing' do
        %w(AWEB AIMAG BWEB IMAG).each do |module_tag|
          it 'should see an image with alt text' do
            html = helper.search_results_by_logo(module_tag)
            expect(html).
              to have_selector(
                "img[alt='Results by Bing']" \
                "[src^='/assets/searches/binglogo_en']"
              )
          end
        end
      end

      context 'when results by Google' do
        %w(GWEB GIMAG).each do |module_tag|
          it 'should see an image with alt text' do
            html = helper.search_results_by_logo(module_tag)
            expect(html).
              to have_selector(
                "img[alt='Results by Google']" \
                "[src^='/assets/searches/googlelogo_en']"
              )
          end
        end
      end

      context 'when results by USASearch' do
        it 'should see an image with alt text' do
          html = helper.search_results_by_logo('whatevs')
          expect(html).
            to have_selector(
              "a[href='https://search.gov'] " \
              "img[alt='Results by USASearch']" \
              "[src^='/assets/searches/results_by_usasearch_en']"
            )
        end
      end
    end

    context 'when locale is es' do
      before(:all) { I18n.locale = :es }
      after(:all) { I18n.locale = I18n.default_locale }

      context 'when results by Bing' do
        %w(BWEB IMAG).each do |module_tag|
          it 'should see an image with alt text' do
            html = helper.search_results_by_logo(module_tag)
            expect(html).
              to have_selector(
                "img[alt='Resultados por Bing']" \
                "[src^='/assets/searches/binglogo_es']"
              )
          end
        end
      end

      context 'when results by Google' do
        %w(GWEB GIMAG).each do |module_tag|
          it 'should see an image with alt text' do
            html = helper.search_results_by_logo(module_tag)
            expect(html).
              to have_selector(
                "img[alt='Resultados por Google']" \
                "[src^='/assets/searches/googlelogo_es']"
              )
          end
        end
      end

      context 'when results by USASearch' do
        it 'should see an image with alt text' do
          html = helper.search_results_by_logo('whatevs')
          expect(html).
            to have_selector(
              "a[href='https://search.gov'] " \
              "img[alt='Resultados por USASearch']" \
              "[src^='/assets/searches/results_by_usasearch_es']"
            )
        end
      end
    end
  end

  describe '#display_web_result_title' do
    it 'should render search results module' do
      result = {'title' => 'USASearch', 'unescapedUrl' => 'http://search.gov'}
      search = double(Search, query: 'gov', module_tag: 'BOGUS_MODULE', spelling_suggestion: nil, queried_at_seconds: 1000)
      html = helper.display_web_result_title(result, search, @affiliate, 1, :web)
      expect(html).to eq("<a href=\"http://search.gov\" onmousedown=\"return clk('gov',this.href, 2, 'usagov', 'BOGUS_MODULE', 1000, 'web', 'en', '')\" >USASearch</a>")
    end
  end

  describe "#link_to_other_web_results(template, query)" do
    let(:html_template) { 'The above results are from Wherever. <a href="http://www.gov.gov/search?query={QUERY}">Try your search again</a> to see results from Another Place.' }
    let(:query) { "one two" }

    it 'should render HTML with interpolated and encoded query string' do
      expect(helper.link_to_other_web_results(html_template, query)).to have_link('Try your search again', 'http://www.gov.gov/search?query=one%20two')
    end
  end
end
