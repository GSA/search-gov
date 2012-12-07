# coding: utf-8
require 'spec_helper'
require 'ostruct'

describe SearchHelper do
  fixtures :affiliates
  before do
    @affiliate = affiliates(:usagov_affiliate)
  end

  describe "#display_web_result_link" do
    it "should shorten really long URLs" do
      result = {}
      result['unescapedUrl'] = "actual content is..."
      result['cacheUrl'] = "...not important here"
      helper.should_receive(:shorten_url).once
      helper.display_web_result_link(result, WebSearch.new(:affiliate => @affiliate), @affiliate, 1, :web)
    end

    it "should render the assigned results module" do
      result = { 'title' => 'USASearch', 'unescapedUrl' => 'http://usasearch.howto.gov' }
      search = mock(Search, query: 'gov', module_tag: 'BOGUS_MODULE', spelling_suggestion: nil, queried_at_seconds: 1000)
      html = helper.display_web_result_link(result, search, @affiliate, 1, :web)
      html.should == "<a href=\"http://usasearch.howto.gov\" onmousedown=\"return clk('gov',this.href, 2, 'usagov', 'BOGUS_MODULE', 1000, 'web', 'en')\" class='link-to-full-url'>http://usasearch.howto.gov</a>"
    end

    context "when affiliate exists" do
      let(:result) { { 'unescapedUrl' => 'http://some.url' } }
      let(:search) { WebSearch.new(:affiliate => @affiliate) }

      it "should not display search within this site link" do
        helper.should_not_receive(:display_search_within_this_site_link).with(result, search, @affiliate).and_return('search_within_this_site_link')
        helper.display_web_result_link(result, search, @affiliate, 1, :web)
      end
    end
  end

  describe "#display_search_within_this_site_link" do
    let(:result) { { 'unescapedUrl' => 'http://WWW1.NPS.GOV/blog/1' } }
    let(:affiliate) { mock('affiliate', :name => 'nps', :locale => 'en', :has_multiple_domains? => false) }
    let(:search) { mock('search', { :query => 'item', :affiliate => affiliate }) }
    let(:params_hash) { { :affiliate => affiliate.name,
                          :locale => I18n.locale,
                          :query => search.query,
                          :sitelimit => 'WWW1.NPS.GOV' } }
    let(:search_path_with_params) { "/search?#{params_hash.to_param}" }

    context "when site_limits present" do
      specify { helper.display_search_within_this_site_link(result, search, affiliate).should be_blank }
    end

    context "when affiliate does not have multiple domains" do
      specify { helper.display_search_within_this_site_link(result, search, affiliate).should be_blank }
    end

    context "when matching affiliate domain is blank, affiliate has multiple domains" do
      before do
        search.should_receive(:matching_site_limits).and_return([])
        affiliate.should_receive(:has_multiple_domains?).and_return(true)
        helper.should_receive(:search_path).with(params_hash).and_return(search_path_with_params)
      end

      it "should generate a search this site link" do
        content = helper.display_search_within_this_site_link(result, search, affiliate)
        content.should have_selector("a[href='#{search_path_with_params}']", :content => 'Search this site')
      end
    end

    context "when locale is :es" do
      before do
        affiliate.stub!(:locale).and_return "es"
      end

      specify { helper.display_search_within_this_site_link(result, search, affiliate).should be_blank }
    end
  end

  describe "#no_news_results_for(search)" do
    let(:search) { NewsSearch.new(:query => '<XSS>', :tbs => "w", :affiliate => affiliates(:basic_affiliate)) }

    it "should HTML escape the query string" do
      helper.no_news_results_for(search).should include("&lt;XSS&gt;")
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
      @urls_that_dont_need_a_box = @urls_that_need_a_box.collect {|url| url.gsub( ".pdf", ".html").gsub( ".PDF", ".HTM").gsub( ".doc", ".html").gsub( ".TXT", ".HTML").gsub( ".txt", ".html") }
      @urls_that_dont_need_a_box << ":"
      @urls_that_dont_need_a_box << "http://www.usa.gov/"
      @urls_that_dont_need_a_box << "http://www.usa.gov/faq"
      @urls_that_dont_need_a_box << "http://www.usa.gov/faq?q=meaning+of+life"
    end

    it "should return empty string for most types of URLs" do
      @urls_that_dont_need_a_box.each do |url|
        helper.display_bing_result_extname_prefix({'unescapedUrl' => url}).should == ""
      end
    end

    it "should return [TYP] span for some URLs" do
      @urls_that_need_a_box.each do |url|
        path_extname = url.gsub(/.*\//,"").gsub(/\?.*/,"").gsub(/[a-zA-Z0-9_]+\./,"").upcase
        prefix = "<span class=\"uext_type\">[#{path_extname.upcase}]</span> "
        helper.display_bing_result_extname_prefix({'unescapedUrl' => url}).should == prefix
      end
    end
  end

  describe "#bing_spelling_suggestion_for(search, affiliate, vertical)" do
    it "should return HTML escaped output containing the initial query and the suggestion" do
      affiliate = affiliates(:basic_affiliate)
      search = WebSearch.new(:query=>"<initialquery>", :affiliate=> affiliate)
      search.stub!(:spelling_suggestion).and_return("<suggestion>")
      html = helper.bing_spelling_suggestion_for(search, affiliate, :web)
      html.should contain("We're including results for <suggestion>. Do you want results only for <initialquery>?")
      html.should =~ /&lt;initialquery&gt;/
      html.should =~ /&lt;suggestion&gt;/
    end
  end

  describe "#shunt_from_bing_to_usasearch" do
    before do
      @bingurl = "http://www.bing.com/search?q=Womans+Health"
    end

    it "should replace Bing search URL with USASearch search URL" do
      helper.shunt_from_bing_to_usasearch(@bingurl, nil).should contain("query=Womans+Health")
    end

    it "should propagate affiliate parameter in URL" do
      helper.shunt_from_bing_to_usasearch(@bingurl, affiliates(:basic_affiliate)).should contain("affiliate=#{affiliates(:basic_affiliate).name}")
    end
  end

  describe "#shorten_url" do

    context "when no truncation length is specified, the URL is too long, has sublevels, but no query params" do
      before do
        #       12345678901234567890123456789012345678901234567890
        #       0        1         2         3         4         5
        @url = "http://www.foo.com/this/is/a/b/c/d/e/f/string.html"
      end

      it "should should default to truncate at 42 characters" do
        #                                          123456789012345678901234567890123456789012
        helper.send(:shorten_url, @url).should == "www.foo.com/this/is/a/.../e/f/string.html"
      end
    end

    context "when URL is too long, has sublevels, but no query params" do
      before do
        #       123456789012345678901234567890
        #       0        1         2         3
        @url = "http://www.foo.com/this/is/a/really/long/url/that/has/no/query/string.html"
      end

      it "should ellipse the directories and just show the file" do
        #                                          123456789012345678901234567890
        helper.send(:shorten_url, @url, 30).should == "www.foo.com/.../string.html"
      end


      it "should replace path segments with ellipses to shorten the path as much as necessary" do
        url_prefix = "http://www.foo.com/this/goes/on/"
        url_middle = ""
        url_suffix = "with/XXX.html"
        0.upto(20) do |n|
          url = url_prefix + url_middle + url_suffix
          url_middle += "and/on/"
          shorter_url = helper.send(:shorten_url, url, 30)
          shorter_url.should == if url.length <= 30
                                  url[7..-1]
                                else
                                  #1234567890123456789012345678901234
                                  "www.foo.com/this/.../XXX.html"
                                end
        end
      end

      it "should replace path segments with ellipses to shorten the path as much as necessary (different path pattern)" do
        url_prefix = "http://www.foo.com/on/"
        url_middle = ""
        url_suffix = "X.html"
        0.upto(20) do |n|
          url = url_prefix + url_middle + url_suffix
          url_middle += "nd/on/"
          shorter_url = helper.send(:shorten_url, url, 30)
          shorter_url.should == if url.length <= 30
                                  url[7..-1]
                                else
                                  #1234567890123456789012345678901234
                                  "www.foo.com/on/.../on/X.html"
                                end
        end
      end
    end

    it "should replace path segments with ellipses to shorten the path as much as necessary for various lengths" do
        url = "http://www.foo.com/this/goes/on/and/on/and/on/with/XXX.html"
        #                                             1234567890123456789012345678901234567890
        helper.send(:shorten_url, url, 20).should == "www.foo.com/.../XXX.html"
        32.upto(34) {|n| helper.send(:shorten_url, url, n).should == "www.foo.com/this/.../XXX.html"}
        35.upto(39) {|n| helper.send(:shorten_url, url, n).should == "www.foo.com/this/.../with/XXX.html"}
        40.upto(42) {|n| helper.send(:shorten_url, url, n).should == "www.foo.com/this/goes/.../with/XXX.html"}
        43.upto(45) {|n| helper.send(:shorten_url, url, n).should == "www.foo.com/this/goes/.../on/with/XXX.html"}
      end

    context "when URL is too long and has at least one sublevel specified as well as a query parameter" do
      before do
        @url = "http://www.foo.com/this/goes/on/and/on/and/on/and/on/and/ends/with/XXXX.html?q=1&a=2&b=3"
      end

      it "should replace path segments with ellipses to shgrten the path as much as necessary, and show only the first param, followed by ellipses" do
        helper.send(:shorten_url, @url, 50).should == "www.foo.com/this/goes/.../with/XXXX.html?q=1..."
      end
    end

    context "when URL is more than 30 chars long and does not have at least one sublevel specified" do
      before do
        @url = "http://www.mass.gov/?pageID=trepressrelease&L=4&L0=Home&L1=Media+%26+Publications&L2=Treasury+Press+Releases&L3=2006&sid=Ctre&b=pressrelease&f=2006_032706&csid=Ctre"
      end

      it "should truncate to 30 chars with ellipses" do
        helper.send(:shorten_url, @url, 30).should == "www.mass.gov/?pageID=trepressrelease..."
      end
    end


    context "when the URL contains a really long host name and a long trailing filename" do
      before do
        @url = "http://www128376218.skjdhfskdjfhs.lqdkwjqlkwjdqlqwkjd.com/some/path/1234567890123456789012345678901234test_of_the_mergency_broadcastingnet_work.html"
      end

      it "should not truncate the host name and truncated the last part of the path" do
        helper.send(:shorten_url, @url, 30).should == "www128376218.skjdhfskdjfhs.lqdkwjqlkwjdqlqwkjd.com/.../123456789012345678901234567890..."
      end
    end


    context "when the URL contains a really long host name and is an http url and has an empty path" do
      before do
        @url = "http://www128376218.skjdhfskdjfhs.lqdkwjqlkwjdqlqwkjd.com/"
      end

      it "should truncate the host name and have no trailing /" do
          helper.send(:shorten_url, @url, 30).should == "www128376218.skjdhfskdjfhs.lqdkwjqlkwjdqlqwkjd.com"
      end
    end


    context "when the URL contains a really long host name and has a really long query parameter" do
      before do
        @url = "http://www128376218.skjdhfskdjfhs.lqdkwjqlkwjdqlqwkjd.com/?cmd=1234567890123456789012345678901234&api_key=1234567890123456789012345678901234"
      end

      it "should not truncate the host name but truncate the query parameter" do
          helper.send(:shorten_url, @url, 30).should == "www128376218.skjdhfskdjfhs.lqdkwjqlkwjdqlqwkjd.com/?cmd=1234567890123456789012345..."
      end
    end


    context "when URL is really short and contains only the protocol http and hostname" do
      it "should omit the protocol as well as trailing slash" do
        helper.send(:shorten_url, "http://bit.ly/").should == "bit.ly"
      end
    end


    context "when URL is really short and contains only the protocol http and hostname and a query parameter" do
      it "should omit the protocol as well as trailing slash" do
        helper.send(:shorten_url, "http://api.bit.ly/?cmd=boom&t=now&auth_token=f886c1c02896492577e92b550cd22b3c83b062").should == "api.bit.ly/?cmd=boom..."
      end

      it "should omit the protocol as well as trailing slash" do
        helper.send(:shorten_url, "http://api.bit.ly/?cmd=boom&t=now").should == "api.bit.ly/?cmd=boom&t=now"
      end
    end

    context "when the URL starts with something other than http://hostname/" do
      before do
        @long_urls = [
            "https://www.mass.gov/",
            "http://www.mass.gov:80/",
            "http://user:secret@www.mass.gov/",
            "https://www.mass.gov/?pageID=trepressrelease&L=4&L0=Home&L1=Media+%26+Publications&L2=Treasury+Press+Releases&L3=2006&sid=Ctre&b=pressrelease&f=2006_032706&csid=Ctre",
            "http://www.mass.gov:80/?pageID=trepressrelease&L=4&L0=Home&L1=Media+%26+Publications&L2=Treasury+Press+Releases&L3=2006&sid=Ctre&b=pressrelease&f=2006_032706&csid=Ctre",
            "http://user:secret@www.mass.gov/?pageID=trepressrelease&L=4&L0=Home&L1=Media+%26+Publications&L2=Treasury+Press+Releases&L3=2006&sid=Ctre&b=pressrelease&f=2006_032706&csid=Ctre",
            "ftp://www.mass.gov/"
        ]
        @short_urls = [
            "https://www.mass.gov/",
            "http://www.mass.gov:80/",
            "http://user:secret@www.mass.gov/",
            "https://www.mass.gov/?pageID=trepressrelease...",
            "http://www.mass.gov:80/?pageID=trepressrelease...",
            "http://user:secret@www.mass.gov/?pageID=trepressrelease...",
            "ftp://www.mass.gov/"
        ]
      end

      it "should truncate to 30 chars with ellipses" do
        @long_urls.each_with_index do |url, x|
          helper.send(:shorten_url, url, 30).should == @short_urls[x]
        end
      end
    end
  end

  describe "#thumbnail_image_tag" do
    before do
      @image_result = {
        "FileSize"=>2555475,
        "Thumbnail"=>{
          "FileSize"=>3728,
          "Url"=>"http://ts1.mm.bing.net/images/thumbnail.aspx?q=327984100492&id=22f3cf1f7970509592422738e08108b1",
          "Width"=>160,
          "Height"=>120,
          "ContentType"=>"image/jpeg"
        },
        "title"=>" ... Inauguration of Barack Obama",
        "MediaUrl"=>"http://www.house.gov/list/speech/mi01_stupak/morenews/Obama.JPG",
        "Url"=>"http://www.house.gov/list/speech/mi01_stupak/morenews/20090120inauguration.html",
        "DisplayUrl"=>"http://www.house.gov/list/speech/mi01_stupak/morenews/20090120inauguration.html",
        "Width"=>3264,
        "Height"=>2448,
        "ContentType"=>"image/jpeg"
      }
    end

    context "for popular images" do
      it "should create an image tag that respects max height and max width when present" do
        helper.send(:thumbnail_image_tag, @image_result, 80, 100).should =~ /width="80"/
        helper.send(:thumbnail_image_tag, @image_result, 80, 100).should =~ /height="60"/

        helper.send(:thumbnail_image_tag, @image_result, 150, 90).should =~ /width="120"/
        helper.send(:thumbnail_image_tag, @image_result, 150, 90).should =~ /height="90"/
      end
    end

    context "for image search results" do
      it "should return an image tag with thumbnail height and width" do
        helper.send(:thumbnail_image_tag, @image_result).should =~ /width="160"/
        helper.send(:thumbnail_image_tag, @image_result).should =~ /height="120"/
      end
    end
  end

  describe "#search_meta_tags" do
    context "for the English site" do
      it "should return English meta tags" do
        helper.should_receive(:english_locale?).and_return(true)
        helper.should_receive(:t).with(:web_meta_description).and_return('English meta description content')
        helper.should_receive(:t).with(:web_meta_keywords).and_return('English meta keywords content')
        content = helper.search_meta_tags
        content.should have_selector("meta[name='description'][content='English meta description content']")
        content.should have_selector("meta[name='keywords'][content='English meta keywords content']")
      end
    end

    context "for Spanish site" do
      it "should return Spanish meta tags" do
        helper.should_receive(:english_locale?).and_return(false)
        helper.should_receive(:spanish_locale?).and_return(true)
        helper.should_receive(:t).with(:web_meta_description).and_return('Spanish meta description content')
        helper.should_receive(:t).with(:web_meta_keywords).and_return('Spanish meta keywords content')
        content = helper.search_meta_tags
        content.should have_selector("meta[name='description'][content='Spanish meta description content']")
        content.should have_selector("meta[name='keywords'][content='Spanish meta keywords content']")
      end
    end

    context "for the non English site" do
      it "should not return meta tags for the non English site" do
        helper.should_receive(:english_locale?).and_return(false)
        helper.search_meta_tags.should == ""
      end
    end
  end

  describe "#path_to_image_search" do
    it "should return images_path if search_params query is blank" do
      search_params = {:locale => I18n.locale}
      helper.path_to_image_search(search_params).should =~ /^\/images/
    end

    it "should return image_searches_path if search_params contains query" do
      search_params = {:query => 'gov', :locale => I18n.locale}
      helper.path_to_image_search(search_params).should =~ /^\/search\/images/
    end
  end

  describe "#image_search_meta_tags" do
    context "for English site" do
      it "should return English meta tags" do
        helper.should_receive(:english_locale?).and_return(true)
        helper.should_receive(:t).with(:image_meta_description).and_return('English image meta description content')
        helper.should_receive(:t).with(:image_meta_keywords).and_return('English image meta keywords content')
        content = helper.image_search_meta_tags
        content.should have_selector("meta[name='description'][content='English image meta description content']")
        content.should have_selector("meta[name='keywords'][content='English image meta keywords content']")
      end
    end

    context "for Spanish site" do
      it "should return Spanish meta tags" do
        helper.should_receive(:english_locale?).and_return(false)
        helper.should_receive(:spanish_locale?).and_return(true)
        helper.should_receive(:t).with(:image_meta_description).and_return('Spanish image meta description content')
        helper.should_receive(:t).with(:image_meta_keywords).and_return('Spanish image meta keywords content')
        content = helper.image_search_meta_tags
        content.should have_selector("meta[name='description'][content='Spanish image meta description content']")
        content.should have_selector("meta[name='keywords'][content='Spanish image meta keywords content']")
      end
    end

    context "for non English or Spanish site" do
      it "should not return meta tags" do
        helper.should_receive(:english_locale?).and_return(false)
        helper.should_receive(:spanish_locale?).and_return(false)
        helper.image_search_meta_tags.should == ""
      end
    end
  end

  describe "#display_image_result_link" do
    before do
      @result = { 'Url' => 'http://aHost.gov/aPath',
                  'title' => 'aTitle',
                  'Thumbnail' => { 'Url' => 'aThumbnailUrl', 'Width' => 40, 'Height' => 30 },
                  'MediaUrl' => 'aMediaUrl' }
      @query = "NASA's"
      @affiliate = mock('affiliate', :name => 'special affiliate name')
      @search = mock('search', { query: @query, queried_at_seconds: Time.now.to_i, spelling_suggestion: nil, module_tag: 'BOGUS_MODULE' })
      @index = 100
      @onmousedown_attr = 'onmousedown attribute'
    end

    it "should generate onmousedown with affiliate name" do
      helper.should_receive(:onmousedown_attribute_for_image_click).
            with(@query, @result['Url'], @index, @affiliate.name, 'BOGUS_MODULE', @search.queried_at_seconds, :image).
            and_return(@onmousedown_attr)
      helper.display_image_result_link(@result, @search, @affiliate, @index, :image)
    end

    it "should generate onmousedown with blank affiliate name if affiliate is nil" do
      helper.should_receive(:onmousedown_attribute_for_image_click).
            with(@query, @result['Url'], @index, "", 'BOGUS_MODULE', @search.queried_at_seconds, :image).
            and_return(@onmousedown_attr)
      helper.display_image_result_link(@result, @search, nil, @index, :image)
    end

    it "should contain tracked links" do
      helper.should_receive(:onmousedown_attribute_for_image_click).
            with(@query, @result['Url'], @index, @affiliate.name, 'BOGUS_MODULE', @search.queried_at_seconds, :image).
            and_return(@onmousedown_attr)
      helper.should_receive(:tracked_click_thumbnail_image_link).with(@result, @onmousedown_attr, 135, 135).and_return("thumbnail_image_link_content")
      helper.should_receive(:tracked_click_thumbnail_link).with(@result, @onmousedown_attr).and_return("thumbnail_link_content")

      content = helper.display_image_result_link(@result, @search, @affiliate, @index, :image)

      content.should contain("thumbnail_image_link_content")
      content.should contain("thumbnail_link_content")
    end

    it "should use spelling suggestion as the query if one exists" do
      @search = mock('search', { query: 'satalate', queried_at_seconds: Time.now.to_i, spelling_suggestion: 'satellite', module_tag: 'BOGUS_MODULE' })
      helper.should_receive(:onmousedown_attribute_for_image_click).
          with("satellite", @result['Url'], @index, @affiliate.name, 'BOGUS_MODULE', @search.queried_at_seconds, :image).
          and_return(@onmousedown_attr)
      helper.display_image_result_link(@result, @search, @affiliate, @index, :image)
    end
  end

  describe "#tracked_click_thumbnail_image_link" do
    before do
      @result = { 'MediaUrl' => 'aUrl', 'title' => 'aTitle', 'Thumbnail' => { 'Url' => 'ThumbnailUrl', 'Width' => 40, 'Height' => 30 } }
      @onmousedown_attr = "onmousedown_attribute"
    end

    it "should return a link to the result url" do
      content = helper.tracked_click_thumbnail_image_link(@result, @onmousedown_attr)
      content.should have_selector("a[href='aUrl'][onmousedown='#{@onmousedown_attr}']")
    end
  end

  describe "#tracked_click_thumbnail_link" do
    before do
      @result = { 'Url' => 'http://aHost.gov/aPath',
                  'title' => 'aTitle',
                  'Thumbnail' => { 'Url' => 'aThumbnailUrl', 'Width' => 40, 'Height' => 30 },
                  'MediaUrl' => 'aMediaUrl' }
      @onmousedown_attr = "onmousedown_attribute"
    end

    it "should be a link to the result thumbnail url" do
      content = helper.tracked_click_thumbnail_link(@result, @onmousedown_attr)
      content.should have_selector("a[href='http://aHost.gov/aPath'][onmousedown='#{@onmousedown_attr}']")
    end
  end

  describe "#onmousedown_attribute_for_image_click" do
    it "should return with escaped query parameter and (index + 1) value" do
      now = Time.now.to_i
      content = helper.onmousedown_attribute_for_image_click("NASA's Space Rock", "mediaUrl", 99, "affiliate name", "SOURCE", now, :image)
      content.should == "return clk('NASA\\&#x27;s Space Rock', 'mediaUrl', 100, 'affiliate name', 'SOURCE', #{now}, 'image', 'en')"
    end
  end

  describe "#tracked_click_link" do
    it "should track spelling suggestion as the query if one exists" do
      search = mock('search', {:query => 'satalite', :queried_at_seconds => Time.now.to_i, :spelling_suggestion => 'satellite'})
      helper.should_receive(:onmousedown_for_click).with(search.spelling_suggestion, 100, '', 'BWEB', search.queried_at_seconds, :image)
      helper.tracked_click_link("aUrl", "aTitle", search, nil, 100, 'BWEB', :image)
    end

    it "should track query if spelling suggestion does not exist" do
      search = mock('search', {:query => 'satalite', :queried_at_seconds => Time.now.to_i, :spelling_suggestion => nil})
      helper.should_receive(:onmousedown_for_click).with(search.query, 100, '', 'BWEB', search.queried_at_seconds, :image)
      helper.tracked_click_link("aUrl", "aTitle", search, nil, 100, 'BWEB', :image)
    end
  end

  describe "#top_search_link" do
    before do
      @top_search_with_url = stub_model(TopSearch, :position => 1, :query => 'query', :url => 'http://test.com/')
      @top_search_without_url_params = { :position => 2, :query => 'another query' }
      @top_search_without_url = stub_model(TopSearch, @top_search_without_url_params)
    end

    it "should return the predefined url if one exists" do
      helper.top_search_link_for(@top_search_with_url).should have_selector("a", :href => @top_search_with_url.url, :content => @top_search_with_url.query, :target => '_top')
    end

    it "should return a search link if url does not exist" do
      url_params = { :linked => 1, :widget_source => 'usa.gov' }
      helper.should_receive(:search_url).with(@top_search_without_url_params.merge(url_params)).and_return('url_with_query_and_source_params')
      helper.top_search_link_for(@top_search_without_url, :widget_source => 'usa.gov').should have_selector("a[href^='url_with_query_and_source_params']", :content => @top_search_without_url.query, :target => '_top')
    end
  end

  describe "#strip_url_protocol" do
    it "should remove protocol from url" do
      strip_url_protocol('http://www.whitehouse.gov').should == 'www.whitehouse.gov'
    end

    it "should remove only the matching prefix protocol" do
      strip_url_protocol('http://www.whitehouse.govhttp://invalidurl').should == 'www.whitehouse.govhttp://invalidurl'
    end

    it "should not remove anything if no matching protocol found" do
      strip_url_protocol('www.whitehouse.gov').should == 'www.whitehouse.gov'
    end
  end

  describe "#display_result_description" do
    it 'should be html safe' do
      search = { 'content' => 'irs' }
      helper.display_result_description(search).should be_html_safe
    end

    it 'should truncate long description' do
      description = <<-DESCRIPTION
The Vietnam War Memorial National Mall Washington, D.C. 2:27 P.M. EDT THE PRESIDENT:  Good afternoon, everybody.
Chuck, thank you for your words and your friendship and your life of service.
Veterans of the Vietnam War, families, friends, distinguished guests. I know it is hot.
      DESCRIPTION
      truncated_description = helper.display_result_description({ 'content' => description })
      truncated_description.should =~ /distinguished \.\.\.$/
      truncated_description.length.should == 255
    end
  end

  describe "#display_search_all_affiliate_sites_suggestion" do
    context "when affiliate is present and matching_site_limits is blank" do
      let(:search) { mock('search') }
      let(:affiliate) { mock('affiliate', :name => 'nps') }

      before do
        search.should_receive(:matching_site_limits).and_return(nil)
      end

      specify { helper.display_search_all_affiliate_sites_suggestion(search, affiliate).should be_blank }
    end

    context "when affiliate is present and matching_site_limits is present" do
      let(:search) { mock('search', :query => 'Yosemite', :site_limits => 'WWW1.NPS.GOV') }
      let(:affiliate) { mock('affiliate', :name => 'nps') }

      it "should display a link to 'Yosemite from all sites'" do
        search.should_receive(:matching_site_limits).exactly(3).times.and_return(['WWW1.NPS.GOV'])
        helper.should_receive(:search_path).with(hash_not_including(:sitelimit)).and_return('search_path_with_params')
        content =  helper.display_search_all_affiliate_sites_suggestion(search, affiliate)
        content.should match /#{Regexp.escape("We're including results for 'Yosemite' from only WWW1.NPS.GOV.")}/
        content.should have_selector("a[href='search_path_with_params']", :content => "'Yosemite' from all sites")
        content.should be_html_safe
      end
    end
  end

  describe "#translate_bing_highlights" do
    let(:excluded_terms) { %w(.mil .gov) }
    let(:body_with_regex_special_character) { "\uE000[Mil\uE001 \uE000.Mil\uE001 .gov" }

    specify { helper.translate_bing_highlights(body_with_regex_special_character, excluded_terms).should == "<strong>[Mil</strong> .Mil .gov" }
  end

  describe '#make_summary_p' do
    context 'when locale = :en' do
      it "should return 'Page %{page} of about %{total} results' when total >= 100 and page > 1" do
        search = mock(Search, :total => 2000, :page => 5, :first_page? => false)
        make_summary_p(search).should == '<p>Page 5 of about 2,000 results</p>'
      end
    end

    context 'when locale = :es' do
      before(:all) { I18n.locale = :es }

      it "should return '1 resultado' when total = 1" do
        search = mock(Search, :total => 1, :first_page? => true)
        make_summary_p(search).should == '<p>1 resultado</p>'
      end

      it "should return 'Página %{page} de %{total} resultados' when total is 2..99 and page > 1" do
        search = mock(Search, :total => 80, :page => 5, :first_page? => false)
        make_summary_p(search).should == '<p>Página 5 de 80 resultados</p>'
      end

      it "should return 'Página %{page} de aproximadamente %{total} resultados' when total >= 100 and page > 1" do
        search = mock(Search, :total => 2000, :page => 5, :first_page? => false)
        make_summary_p(search).should == '<p>Página 5 de aproximadamente 2,000 resultados</p>'
      end

      after(:all) { I18n.locale = I18n.default_locale }
    end
  end

  describe '#search_results_by_logo' do
    context 'when results by Bing and locale is en' do
      before(:all) { I18n.locale = :en }
      after(:all) { I18n.locale = I18n.default_locale }

      it 'should see an image with alt text' do
        html = helper.search_results_by_logo(true)
        html.should have_selector("img[alt='Results by Bing'][src^='/images/binglogo_en.gif']")
      end
    end

    context 'when results by Bing and locale is es' do
      before(:all) { I18n.locale = :es }
      after(:all) { I18n.locale = I18n.default_locale }

      it 'should see an image with alt text' do
        html = helper.search_results_by_logo(true)
        html.should have_selector("img[alt='Resultados por Bing'][src^='/images/binglogo_es.gif']")
      end
    end

    context 'when results by USASearch and locale is en' do
      before(:all) { I18n.locale = :en }
      after(:all) { I18n.locale = I18n.default_locale }

      it 'should see an image with alt text' do
        html = helper.search_results_by_logo(false)
        html.should have_selector("a[href='http://usasearch.howto.gov'] img[alt='Results by USASearch'][src^='/images/results_by_usasearch_en.png']")
      end
    end

    context 'when results by USASearch and locale is es' do
      before(:all) { I18n.locale = :es }
      after(:all) { I18n.locale = I18n.default_locale }

      it 'should see an image with alt text' do
        html = helper.search_results_by_logo(false)
        html.should have_selector("a[href='http://usasearch.howto.gov'] img[alt='Resultados por USASearch'][src^='/images/results_by_usasearch_es.png']")
      end
    end
  end

  describe '#display_web_result_title' do
    it 'should render search results module' do
      result = { 'title' => 'USASearch', 'unescapedUrl' => 'http://usasearch.howto.gov' }
      search = mock(Search, query: 'gov', module_tag: 'BOGUS_MODULE', spelling_suggestion: nil, queried_at_seconds: 1000)
      html = helper.display_web_result_title(result, search, @affiliate, 1, :web)
      html.should == "<a href=\"http://usasearch.howto.gov\" onmousedown=\"return clk('gov',this.href, 2, 'usagov', 'BOGUS_MODULE', 1000, 'web', 'en')\" >USASearch</a>"
    end
  end
end
