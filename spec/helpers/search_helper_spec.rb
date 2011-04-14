require "#{File.dirname(__FILE__)}/../spec_helper"
require 'ostruct'

describe SearchHelper do
  fixtures :affiliates

  describe "#display_result_links" do
    it "should shorten really long URLs" do
      result = {}
      result['unescapedUrl'] = "actual content is..."
      result['cacheUrl'] = "...not important here"
      helper.should_receive(:shorten_url).once
      helper.display_result_links(result, Search.new, Affiliate.new, 1)
    end
  end

  describe "#render_spotlight_with_click_tracking(spotlight_html, query, queried_at_seconds)" do
    it "should add indexed mousedowns to each link" do
      spotlight_html = "<li><a href='foo'>bar</a></li><li><a href='blat'>baz</a></li>"
      query = "bdd"
      queried_at_seconds = 1271978870
      html = helper.render_spotlight_with_click_tracking(spotlight_html, query, queried_at_seconds)
      html.should == "<li><a href=\"foo\" onmousedown=\"return clk('bdd',this.href, 1, '', 'SPOT', 1271978870)\">bar</a></li><li><a href=\"blat\" onmousedown=\"return clk('bdd',this.href, 2, '', 'SPOT', 1271978870)\">baz</a></li>"
    end
  end

  describe "#spelling_suggestion(search, affiliate)" do
    it "should return HTML escaped output containing the initial query and the suggestion" do
      affiliate = affiliates(:basic_affiliate)
      search = Search.new(:query=>"<initialquery>", :affiliate=> affiliate)
      search.stub!(:spelling_suggestion).and_return("<suggestion>")
      html = helper.spelling_suggestion(search, affiliate)
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
    context "when URL is more than 30 chars, has sublevels, but no query params" do
      before do
        @url = "http://www.foo.com/this/is/a/really/long/url/that/has/no/query/string.html"
      end

      it "should ellipse the directories and just show the file" do
        helper.send(:shorten_url, @url).should == "http://www.foo.com/.../string.html"
      end
    end

    context "when URL is more than 30 chars long and has at least one sublevel specified" do
      before do
        @url = "http://www.foo.com/this/goes/on/and/on/and/on/and/on/and/ends/with/XXXX.html?q=1&a=2&b=3"
      end

      it "should replace everything between the hostname and the document with ellipses, and show only the first param, followed by ellipses" do
        helper.send(:shorten_url, @url).should == "http://www.foo.com/.../XXXX.html?q=1..."
      end
    end

    context "when URL is more than 30 chars long and does not have at least one sublevel specified" do
      before do
        @url = "http://www.mass.gov/?pageID=trepressrelease&L=4&L0=Home&L1=Media+%26+Publications&L2=Treasury+Press+Releases&L3=2006&sid=Ctre&b=pressrelease&f=2006_032706&csid=Ctre"
      end

      it "should truncate to 30 chars with ellipses" do
        helper.send(:shorten_url, @url).should == "http://www.mass.gov/?pageID=tr..."
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

  describe "#display_deep_links_for(result)" do
    before do
      deep_links=[]
      8.times { |idx| deep_links << OpenStruct.new(:title=>"title #{idx}", :url => "url #{idx}") }
      @result = {"title"=>"my title", "deepLinks"=>deep_links, "cacheUrl"=>"cached", "content"=>"Some content", "unescapedUrl"=>"http://www.gsa.gov/someurl"}
    end

    context "when there are no deep links" do
      before do
        @result['deepLinks']=nil
      end
      it "should return nil" do
        helper.display_deep_links_for(@result).should be_nil
      end
    end

    context "when there are deep links" do
      it "should render deep links in two columns" do
        html = helper.display_deep_links_for(@result)
        html.should match("<tr><td><a href=\"url 0\">title 0</a></td><td><a href=\"url 1\">title 1</a></td></tr><tr><td><a href=\"url 2\">title 2</a></td><td><a href=\"url 3\">title 3</a></td></tr><tr><td><a href=\"url 4\">title 4</a></td><td><a href=\"url 5\">title 5</a></td></tr><tr><td><a href=\"url 6\">title 6</a></td><td><a href=\"url 7\">title 7</a></td></tr>")
      end
    end

    context "when there are more than 8 deep links" do
      before do
        @result['deepLinks'] << OpenStruct.new(:title=>"ninth title", :url => "ninth url")
      end

      it "should show a maximum of 8 deep links" do
        html = helper.display_deep_links_for(@result)
        html.should_not match(/ninth/)
      end
    end

    context "when there are an odd number of deep links" do
      before do
        @result['deepLinks']= @result['deepLinks'].slice(0..-2)
      end

      it "should have an empty last spot" do
        html = helper.display_deep_links_for(@result)
        html.should match("<tr><td><a href=\"url 6\">title 6</a></td><td></td></tr>")
      end
    end
  end

  describe "#agency_url_matches_by_locale" do
    before do
      @agency = Agency.create(:name => 'My Agency', :domain => 'myagency.gov', :url => 'http://www.myagency.gov/')
    end

    context "when the locale is neither english or spanish" do
      it "should return false" do
        helper.agency_url_matches_by_locale('http://www.myagency.gov/', @agency, :tk).should == false
      end
    end
  end

  describe "#search_meta_tags" do
    context "for the English site" do
      it "should return meta tags for the English site" do
        helper.should_receive(:english_locale?).and_return(true)
        content = helper.search_meta_tags
        content.should have_tag("meta[name=description][content=Search.USA.gov is the U.S. government's official search engine.]")
        content.should have_tag("meta[name=keywords][content=government images, government forms, government recalls, federal government, state government, american government, united states government, us government, government jobs, SearchUSAgov, USASearch, USA Search, SearchUSA, Firstgov search, first gov search, USAGovSearch, USA gov search, government websites, government web]")
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
    context "for the English site" do
      it "should return meta tags for the English site" do
        helper.should_receive(:english_locale?).and_return(true)
        content = helper.image_search_meta_tags
        content.should have_tag("meta[name=description][content=Search.USA.gov Images is the U.S. government's official search engine for images.]")
        content.should have_tag("meta[name=keywords][content=government images, government imagery, government photographs, government photos, government photography, public domain images, copyright free images, satellite, american flag images, SearchUSAgov, USASearch, USA Search, SearchUSA, Firstgov search, first gov search, USAGovSearch, USA gov search, government websites, government web]")
      end
    end

    context "for the non English site" do
      it "should not return meta tags for the non English site" do
        helper.should_receive(:english_locale?).and_return(false)
        helper.image_search_meta_tags.should == ""
      end
    end
  end

  describe "#display_image_result_links" do
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
            with(@query, @result['MediaUrl'], @index, @affiliate.name, "IMAG", @search.queried_at_seconds).
            and_return(@onmousedown_attr)
      helper.display_image_result_links(@result, @search, @affiliate, @index)
    end

    it "should generate onmousedown with blank affiliate name if affiliate is nil" do
      helper.should_receive(:onmousedown_attribute_for_image_click).
            with(@query, @result['MediaUrl'], @index, "", "IMAG", @search.queried_at_seconds).
            and_return(@onmousedown_attr)
      helper.display_image_result_links(@result, @search, nil, @index)
    end

    it "should contain tracked links" do
      helper.should_receive(:onmousedown_attribute_for_image_click).
            with(@query, @result['MediaUrl'], @index, @affiliate.name, "IMAG", @search.queried_at_seconds).
            and_return(@onmousedown_attr)
      helper.should_receive(:tracked_click_thumbnail_image_link).with(@result, @onmousedown_attr).and_return("thumbnail_image_link_content")
      helper.should_receive(:tracked_click_thumbnail_link).with(@result, @onmousedown_attr).and_return("thumbnail_link_content")

      content = helper.display_image_result_links(@result, @search, @affiliate, @index)

      content.should contain("thumbnail_image_link_content")
      content.should contain("thumbnail_link_content")
    end

    it "should use spelling suggestion as the query if one exists" do
      @search = mock('search', {:query => 'satalate', :queried_at_seconds => Time.now.to_i, :spelling_suggestion => 'satellite'})
      helper.should_receive(:onmousedown_attribute_for_image_click).
          with("satellite", @result['MediaUrl'], @index, @affiliate.name, "IMAG", @search.queried_at_seconds).
          and_return(@onmousedown_attr)
      helper.display_image_result_links(@result, @search, @affiliate, @index)
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
            with(@query, @result['MediaUrl'], @index, nil, "IMAG", @search.queried_at_seconds).
            and_return(@onmousedown_attr)
      helper.should_receive(:tracked_click_thumbnail_image_link).with(@result, @onmousedown_attr, 140, 90).and_return("thumbnail_image_link_content")
      content = helper.display_thumbnail_image_link(@result, @search, @index, 140, 90)
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
      content.should have_tag("a[href=aUrl][onmousedown=#{@onmousedown_attr}]")
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
      content.should have_tag("a[href=aMediaUrl][onmousedown=#{@onmousedown_attr}]")
    end
  end

  describe "#onmousedown_attribute_for_image_click" do
    it "should return with escaped query parameter and (index + 1) value" do
      now = Time.now.to_i
      content = helper.onmousedown_attribute_for_image_click("NASA's Space Rock", "mediaUrl", 99, "affiliate name", "SOURCE", now)
      content.should == "return clk('NASA\\'s Space Rock', 'mediaUrl', 100, 'affiliate name', 'SOURCE', #{now})"
    end
  end

  describe "#tracked_click_link" do
    it "should track spelling suggestion as the query if one exists" do
      search = mock('search', {:query => 'satalite', :queried_at_seconds => Time.now.to_i, :spelling_suggestion => 'satellite'})
      helper.should_receive(:onmousedown_for_click).with(search.spelling_suggestion, 100, '', 'BWEB', search.queried_at_seconds)
      helper.tracked_click_link("aUrl", "aTitle", search, nil, 100, 'BWEB')
    end

    it "should track query if spelling suggestion does not exist" do
      search = mock('search', {:query => 'satalite', :queried_at_seconds => Time.now.to_i, :spelling_suggestion => nil})
      helper.should_receive(:onmousedown_for_click).with(search.query, 100, '', 'BWEB', search.queried_at_seconds)
      helper.tracked_click_link("aUrl", "aTitle", search, nil, 100, 'BWEB')
    end
  end
end
