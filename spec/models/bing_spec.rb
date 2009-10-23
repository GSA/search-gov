require "#{File.dirname(__FILE__)}/../spec_helper"
describe Bing do
  common_search = "http://api.search.live.net/json.aspx?web.offset=0&AppId=A4C32FAE6F3DB386FC32ED1C4F3024742ED30906&sources=Spell+Web+RelatedSearch+Image&Options=EnableHighlighting&query=government%20"
  describe "#run" do
    context "when non-English locale is specified" do
      before do
        I18n.locale = :es
      end

      it "should pass a language filter to Bing" do
        uriresult = URI::parse("http://127.0.0.1:64000/noop")
        bing = Bing.new(:query => "government", :affiliate => nil, :page => 0)
        URI.should_receive(:parse).with("#{common_search}(site:gov%20OR%20site:mil)%20language:es").and_return(uriresult)
        bing.run
      end

      after do
        I18n.locale = I18n.default_locale
      end
    end

    context "when affiliate has domains specified" do
      it "should use domains in query to Bing" do
        affiliate = Affiliate.new(:domains => %w(foo.com bar.com).join("\n"))
        uriresult = URI::parse("http://127.0.0.1:64000/noop")
        bing = Bing.new(:query => "government", :affiliate => affiliate, :page => 0)
        URI.should_receive(:parse).with("#{common_search}(site:foo.com%20OR%20site:bar.com)").and_return(uriresult)
        bing.run
      end
    end

    context "when affiliate has no domains specified" do
      it "should use just query string and mil&gov domain filters" do
        affiliate = Affiliate.new
        uriresult = URI::parse("http://127.0.0.1:64000/noop")
        bing = Bing.new(:query => "government", :affiliate => affiliate, :page => 0)
        URI.should_receive(:parse).with("#{common_search}(site:gov%20OR%20site:mil)").and_return(uriresult)
        bing.run
      end
    end

    context "when affiliate is nil" do
      it "should use just query string and mil&gov domain filters" do
        uriresult = URI::parse("http://127.0.0.1:64000/noop")
        bing = Bing.new(:query => "government", :affiliate => nil, :page => 0)
        URI.should_receive(:parse).with("#{common_search}(site:gov%20OR%20site:mil)").and_return(uriresult)
        bing.run
      end
    end

    context "when page offset is specified" do
      it "should specify the offset in the query to Bing" do
        uriresult = URI::parse("http://127.0.0.1:64000/noop")
        bing = Bing.new(:query => "government", :affiliate => nil, :page => 7)
        URI.should_receive(:parse).with("#{common_search.sub("offset=0", "offset=70")}(site:gov%20OR%20site:mil)").and_return(uriresult)
        bing.run
      end
    end
  end
end
