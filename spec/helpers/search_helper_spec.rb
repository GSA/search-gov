require "#{File.dirname(__FILE__)}/../spec_helper"
require 'ostruct'

describe SearchHelper do
  describe "#display_result_links" do
    it "should shorten really long URLs" do
      result = {}
      result['unescapedUrl'] = "actual content is..."
      result['cacheUrl'] = "...not important here"
      helper.should_receive(:shorten_url).once
      helper.display_result_links(result)
    end
  end

  describe "#highlight_except(str, except)" do
    context "when str does not contain any words from except string" do
      before do
        @str = "some title string"
        @except = "foo"
      end

      it "should return str with all words highlighted" do
        helper.highlight_except(@str, @except).should == "<strong>some</strong> <strong>title</strong> <strong>string</strong>"
      end
    end

    context "when str contains words from except string regardless of case" do
      before do
        @str = "some title string With words"
      end

      it "should return str with all words highlighted except the group of words contained in the except string" do
        @except = "title with"
        helper.highlight_except(@str, @except).should == "<strong>some</strong> title <strong>string</strong> With <strong>words</strong>"
      end
    end
  end

  describe "#shorten_url" do
    context "when URL is more than 30 chars long and has at least one sublevel specified" do
      before do
        @url = "http://www.foo.com/this/goes/on/and/on/and/on/and/on/and/ends/with/XXXX.html?q=1&a=2&b=3"
      end

      it "should replace everything between the hostname and the document with ellipses and remove params" do
        helper.send(:shorten_url, @url).should == "http://www.foo.com/.../XXXX.html"
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

  describe "#display_deep_links_for(result,query)" do
    before do
      deep_links=[]
      8.times {|idx| deep_links << OpenStruct.new(:title=>"title #{idx}", :url => "url #{idx}")}
      @result = {"title"=>"my title", "deepLinks"=>deep_links, "cacheUrl"=>"cached", "content"=>"Some content", "unescapedUrl"=>"http://www.gsa.gov/someurl"}
      @query = "some query"
    end

    context "when there are no deep links" do
      before do
        @result['deepLinks']=nil
      end
      it "should return nil" do
        helper.display_deep_links_for(@result, @query).should be_nil
      end
    end

    context "when there are deep links" do
      it "should render deep links in two columns" do
        html = helper.display_deep_links_for(@result, @query)
        html.should match("<tr><td><a href=\"url 0\">title 0</a></td><td><a href=\"url 1\">title 1</a></td></tr><tr><td><a href=\"url 2\">title 2</a></td><td><a href=\"url 3\">title 3</a></td></tr><tr><td><a href=\"url 4\">title 4</a></td><td><a href=\"url 5\">title 5</a></td></tr><tr><td><a href=\"url 6\">title 6</a></td><td><a href=\"url 7\">title 7</a></td></tr>")
      end
    end

    context "when there are more than 8 deep links" do
      before do
        @result['deepLinks'] << OpenStruct.new(:title=>"ninth title", :url => "ninth url")
      end

      it "should show a maximum of 8 deep links" do
        html = helper.display_deep_links_for(@result, @query)
        html.should_not match(/ninth/)
      end
    end

    context "when there are an odd number of deep links" do
      before do
        @result['deepLinks']= @result['deepLinks'].slice(0..-2)
      end

      it "should have an empty last spot" do
        html = helper.display_deep_links_for(@result, @query)
        html.should match("<tr><td><a href=\"url 6\">title 6</a></td><td></td></tr>")
      end
    end

    context "when query term has no site: filter" do
      it "should show a more results link" do
        html = helper.display_deep_links_for(@result, @query)
        html.should match("Show more results from www.gsa.gov</a>")
      end
    end

    context "when query term has a site: filter" do
      before do
        @query = "site:www.gsa.gov #{@query}"
      end

      it "should not show a more results link" do
        html = helper.display_deep_links_for(@result, @query)
        html.should_not match("Show more results")
      end
    end
  end
end