require 'spec/spec_helper'
require 'ostruct'

describe SearchHelper do
  fixtures :affiliates

  describe "#display_bing_result_links" do
    it "should shorten really long URLs" do
      result = {}
      result['unescapedUrl'] = "actual content is..."
      result['cacheUrl'] = "...not important here"
      helper.should_receive(:shorten_url).once
      helper.display_bing_result_links(result, Search.new, Affiliate.new, 1, :web)
    end

    context "when affiliate exists" do
      let(:result) { { 'unescapedUrl' => 'http://some.url' } }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:search) { Search.new }

      it "should not display search within this site link" do
        helper.should_not_receive(:display_search_within_this_site_link).with(result, search, affiliate).and_return('search_within_this_site_link')
        helper.display_bing_result_links(result, search, affiliate, 1, :web)
      end
    end
  end

  describe "#display_search_within_this_site_link" do
    context "when affiliate is nil" do
      let(:result) { { 'unescapedUrl' => 'http://WWW.NPS.GOV/blog/1' } }
      let(:search) { mock('search', { :query => 'item' }) }
      let(:affiliate) { nil }

      specify { helper.display_search_within_this_site_link(result, search, affiliate).should be_blank }
    end

    context "when affiliate is not nil" do
      let(:result) { { 'unescapedUrl' => 'http://WWW1.NPS.GOV/blog/1' } }
      let(:affiliate) { mock('affiliate', :name => 'nps') }
      let(:search) { mock('search', { :query => 'item' }) }
      let(:params_hash) { { :affiliate => affiliate.name,
                            :locale => I18n.locale,
                            :query => search.query,
                            :sitelimit => 'WWW1.NPS.GOV' } }
      let(:search_path_with_params) { "/search?#{params_hash.to_param}" }

      context "when site_limits present" do
        before do
          search.should_receive(:matching_site_limit).and_return('WWW1.NPS.GOV')
        end

        specify { helper.display_search_within_this_site_link(result, search, affiliate).should be_blank }
      end

      context "when affiliate does not have multiple domains" do
        before do
          search.should_receive(:matching_site_limit).and_return(nil)
          affiliate.should_receive(:has_multiple_domains?).and_return(false)
        end

        specify { helper.display_search_within_this_site_link(result, search, affiliate).should be_blank }
      end

      context "when matching affiliate domain is blank, affiliate has multiple domains" do
        before do
          search.should_receive(:matching_site_limit).and_return(nil)
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
          I18n.stub(:locale).with(no_args).and_return(:es)
        end

        specify { helper.display_search_within_this_site_link(result, search, affiliate).should be_blank }
      end
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

  describe "#render_spotlight_with_click_tracking(spotlight_html, query, queried_at_seconds)" do
    it "should add indexed mousedowns to each link" do
      spotlight_html = "<li><a href='foo'>bar</a></li><li><a href='blat'>baz</a></li>"
      query = "bdd"
      queried_at_seconds = 1271978870
      html = helper.render_spotlight_with_click_tracking(spotlight_html, query, queried_at_seconds, :web)
      html.should == "<li><a href=\"foo\" onmousedown=\"return clk('bdd',this.href, 1, '', 'SPOT', 1271978870, 'web', 'en')\">bar</a></li><li><a href=\"blat\" onmousedown=\"return clk('bdd',this.href, 2, '', 'SPOT', 1271978870, 'web', 'en')\">baz</a></li>"
    end
  end

  describe "#bing_spelling_suggestion_for(search, affiliate, vertical)" do
    it "should return HTML escaped output containing the initial query and the suggestion" do
      affiliate = affiliates(:basic_affiliate)
      search = Search.new(:query=>"<initialquery>", :affiliate=> affiliate)
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

  describe "#display_deep_links_for(result, search, affiliate, vertical)" do
    before do
      deep_links=[]
      8.times { |idx| deep_links << OpenStruct.new(:title=>"title #{idx}", :url => "url #{idx}") }
      @result = {"title"=>"my title", "deepLinks"=>deep_links, "cacheUrl"=>"cached", "content"=>"Some content", "unescapedUrl"=>"http://www.gsa.gov/someurl"}
      @search = mock("Search", :query => "q", :spelling_suggestion => "x", :queried_at_seconds => Time.now.to_i)
      @affiliate = affiliates(:power_affiliate)
    end

    context "when there are no deep links" do
      before do
        @result['deepLinks']=nil
      end
      it "should return nil" do
        helper.display_deep_links_for(@result, @search, @affiliate, :web).should be_nil
      end
    end

    context "when there are deep links" do
      it "should render deep links in two columns" do
        html = helper.display_deep_links_for(@result, @search, @affiliate, :web)
        html.should match("<tr><td><a href=\"url 0\".*>title 0</a></td><td><a href=\"url 1\".*>title 1</a></td></tr><tr><td><a href=\"url 2\".*>title 2</a></td><td><a href=\"url 3\".*>title 3</a></td></tr><tr><td><a href=\"url 4\".*>title 4</a></td><td><a href=\"url 5\".*>title 5</a></td></tr><tr><td><a href=\"url 6\".*>title 6</a></td><td><a href=\"url 7\".*>title 7</a></td></tr>")
      end
    end

    context "when there are more than 8 deep links" do
      before do
        @result['deepLinks'] << OpenStruct.new(:title=>"ninth title", :url => "ninth url")
      end

      it "should show a maximum of 8 deep links" do
        html = helper.display_deep_links_for(@result, @search, @affiliate, :web)
        html.should_not match(/ninth/)
      end
    end

    context "when there are an odd number of deep links" do
      before do
        @result['deepLinks']= @result['deepLinks'].slice(0..-2)
      end

      it "should have an empty last spot" do
        html = helper.display_deep_links_for(@result, @search, @affiliate, :web)
        html.should match("title 6</a></td><td></td></tr></table>")
      end
    end
  end

  describe "#agency_url_matches_by_locale" do
    before do
      @agency = Agency.create(:name => 'My Agency', :domain => 'myagency.gov')
      @agency.agency_urls << AgencyUrl.new(:url => 'http://www.myagency.gov/', :locale => 'en')
    end

    context "when the locale is neither english or spanish" do
      it "should return false" do
        helper.agency_url_matches_by_locale('http://www.myagency.gov/', @agency, :tk).should == false
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

  describe "#display_bing_image_result_links" do
    before do
      @result = { 'Url' => 'http://aHost.gov/aPath',
                  'title' => 'aTitle',
                  'Thumbnail' => { 'Url' => 'aThumbnailUrl', 'Width' => 40, 'Height' => 30 },
                  'MediaUrl' => 'aMediaUrl' }
      @query = "NASA's"
      @affiliate = mock('affiliate', :name => 'special affiliate name')
      @search = mock('search', {:query => @query, :queried_at_seconds => Time.now.to_i, :spelling_suggestion => nil})
      @index = 100
      @onmousedown_attr = 'onmousedown attribute'
    end

    it "should generate onmousedown with affiliate name" do
      helper.should_receive(:onmousedown_attribute_for_image_click).
            with(@query, @result['MediaUrl'], @index, @affiliate.name, "IMAG", @search.queried_at_seconds, :image).
            and_return(@onmousedown_attr)
      helper.display_bing_image_result_links(@result, @search, @affiliate, @index, :image)
    end

    it "should generate onmousedown with blank affiliate name if affiliate is nil" do
      helper.should_receive(:onmousedown_attribute_for_image_click).
            with(@query, @result['MediaUrl'], @index, "", "IMAG", @search.queried_at_seconds, :image).
            and_return(@onmousedown_attr)
      helper.display_bing_image_result_links(@result, @search, nil, @index, :image)
    end

    it "should contain tracked links" do
      helper.should_receive(:onmousedown_attribute_for_image_click).
            with(@query, @result['MediaUrl'], @index, @affiliate.name, "IMAG", @search.queried_at_seconds, :image).
            and_return(@onmousedown_attr)
      helper.should_receive(:tracked_click_thumbnail_image_link).with(@result, @onmousedown_attr).and_return("thumbnail_image_link_content")
      helper.should_receive(:tracked_click_thumbnail_link).with(@result, @onmousedown_attr).and_return("thumbnail_link_content")

      content = helper.display_bing_image_result_links(@result, @search, @affiliate, @index, :image)

      content.should contain("thumbnail_image_link_content")
      content.should contain("thumbnail_link_content")
    end

    it "should use spelling suggestion as the query if one exists" do
      @search = mock('search', {:query => 'satalate', :queried_at_seconds => Time.now.to_i, :spelling_suggestion => 'satellite'})
      helper.should_receive(:onmousedown_attribute_for_image_click).
          with("satellite", @result['MediaUrl'], @index, @affiliate.name, "IMAG", @search.queried_at_seconds, :image).
          and_return(@onmousedown_attr)
      helper.display_bing_image_result_links(@result, @search, @affiliate, @index, :image)
    end
  end

  describe "#display_thumbnail_image_link" do
    before do
      @result = { 'Url' => 'http://aHost.gov/aPath',
                  'title' => 'aTitle',
                  'Thumbnail' => { 'Url' => 'aThumbnailUrl', 'Width' => 280, 'Height' => 180 },
                  'MediaUrl' => 'aMediaUrl' }
      @query = "NASA's"
      @search = mock('search', {:query => @query, :queried_at_seconds => Time.now.to_i})
      @index = 100
      @onmousedown_attr = 'onmousedown attribute'
    end

    it "should contain tracked thumbnail image link" do
      helper.should_receive(:onmousedown_attribute_for_image_click).
            with(@query, @result['MediaUrl'], @index, nil, "IMAG", @search.queried_at_seconds, :image).
            and_return(@onmousedown_attr)
      helper.should_receive(:tracked_click_thumbnail_image_link).with(@result, @onmousedown_attr, 140, 90).and_return("thumbnail_image_link_content")
      content = helper.display_thumbnail_image_link(@result, @search, @index, :image, 140, 90)
      content.should contain("thumbnail_image_link_content")
    end
  end

  describe "#tracked_click_thumbnail_image_link" do
    before do
      @result = { 'Url' => 'aUrl', 'title' => 'aTitle', 'Thumbnail' => { 'Url' => 'ThumbnailUrl', 'Width' => 40, 'Height' => 30 } }
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
      content.should have_selector("a[href='aMediaUrl'][onmousedown='#{@onmousedown_attr}']")
    end
  end

  describe "#onmousedown_attribute_for_image_click" do
    it "should return with escaped query parameter and (index + 1) value" do
      now = Time.now.to_i
      content = helper.onmousedown_attribute_for_image_click("NASA's Space Rock", "mediaUrl", 99, "affiliate name", "SOURCE", now, :image)
      content.should == "return clk('NASA\\'s Space Rock', 'mediaUrl', 100, 'affiliate name', 'SOURCE', #{now}, 'image', 'en')"
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
      extra_url_params = { :linked => 1 }
      helper.should_receive(:search_url).with(@top_search_without_url_params.merge(extra_url_params)).and_return('http://test.host/search')
      helper.top_search_link_for(@top_search_without_url).should have_selector("a[href^='http://test.host/search']", :content => @top_search_without_url.query, :target => '_top')
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

  describe "#display_agency_link" do
    it "should remove url protocol" do
      search = mock('search', { :query => 'space', :queried_at_seconds => Time.now.to_i, :spelling_suggestion => nil })
      result = { 'unescapedUrl' => 'http://www.whitehouse.gov' }
      helper.should_receive(:tracked_click_link).with(result['unescapedUrl'], 'www.whitehouse.gov', search, nil, 0, 'BWEB', :web, "class='link-to-full-url'").and_return('tracked')
      helper.display_agency_link(result, search, nil, 0, :web).should == 'tracked'
    end
  end

  describe "#display_result_description" do
    before do
      search = { 'content' => 'irs' }
      @description = helper.display_result_description(search)
    end

    specify { @description.should be_html_safe }
  end

  describe "#display_search_all_affiliate_sites_suggestion" do

    context "when affiliate is nil" do
      specify { helper.display_search_all_affiliate_sites_suggestion(Search.new, nil).should be_blank }
    end

    context "when affiliate is present and matching_site_limit is blank" do
      let(:matching_site_limit) { mock('matching_site_limit') }
      let(:search) { mock('search') }
      let(:affiliate) { mock('affiliate', :name => 'nps') }

      before do
        search.should_receive(:matching_site_limit).and_return(matching_site_limit)
        matching_site_limit.should_receive(:present?).and_return(false)
      end

      specify { helper.display_search_all_affiliate_sites_suggestion(search, affiliate).should be_blank }
    end

    context "when affiliate is present and matching_site_limit is present" do
      let(:search) { mock('search', :query => 'Yosemite', :site_limits => 'WWW1.NPS.GOV') }
      let(:affiliate) { mock('affiliate', :name => 'nps') }

      it "should display a link to 'Yosemite from all sites'" do
        search.should_receive(:matching_site_limit).twice.and_return('WWW1.NPS.GOV')
        helper.should_receive(:search_path).with(hash_not_including(:sitelimit)).and_return('search_path_with_params')
        content =  helper.display_search_all_affiliate_sites_suggestion(search, affiliate)
        content.should match /#{Regexp.escape("We're including results for 'Yosemite' from only WWW1.NPS.GOV.")}/
        content.should have_selector("a[href='search_path_with_params']", :content => "'Yosemite' from all sites")
        content.should be_html_safe
      end
    end
  end

  describe "#display_affiliate_favicon" do
    let(:affiliate) { mock('affiliate', :name => 'nps') }

    context "when favicon_url is not blank" do
      before do
        affiliate.should_receive(:favicon_url).and_return("http://cdn.agency.gov/favicon.ico")
      end

      specify { helper.display_affiliate_favicon(affiliate).should == 'http://cdn.agency.gov/favicon.ico' }
    end

    context "when favicon_url is blank" do
      before do
        affiliate.should_receive(:favicon_url).and_return(nil)
      end

      specify { helper.display_affiliate_favicon(affiliate).should == '/favicon.ico' }
    end
  end
end
