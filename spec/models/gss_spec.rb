require "#{File.dirname(__FILE__)}/../spec_helper"
describe Gss do

  describe "#run" do
    context "when affiliate has domains specified" do
      it "should use domains in query string" do
        affiliate = Affiliate.new(:domains => %w(foo.com bar.com).join("\n"))
        uriresult = URI::parse("http://127.0.0.1:64000/noop")
        gss = Gss.new(:query => "government", :affiliate => affiliate, :page => 0)
        URI.should_receive(:parse).with("http://www.google.com/search?client=google-csbe&cx=009969014417352305501:4bohptsvhei&ie=utf8&num=20&oe=utf8&output=xml_no_dtd&q=government%20site:foo.com%20OR%20site:bar.com&start=0").and_return(uriresult)
        gss.run
      end
    end

    context "when affiliate has no domains specified" do
      it "should use just query string" do
        affiliate = Affiliate.new
        uriresult = URI::parse("http://127.0.0.1:64000/noop")
        gss = Gss.new(:query => "government", :affiliate => affiliate, :page => 0)
        URI.should_receive(:parse).with("http://www.google.com/search?client=google-csbe&cx=009969014417352305501:4bohptsvhei&ie=utf8&num=20&oe=utf8&output=xml_no_dtd&q=government&start=0").and_return(uriresult)
        gss.run
      end
    end

    context "when affiliate is nil" do
      it "should use just query string" do
        uriresult = URI::parse("http://127.0.0.1:64000/noop")
        gss = Gss.new(:query => "government", :affiliate => nil, :page => 0)
        URI.should_receive(:parse).with("http://www.google.com/search?client=google-csbe&cx=009969014417352305501:4bohptsvhei&ie=utf8&num=20&oe=utf8&output=xml_no_dtd&q=government&start=0").and_return(uriresult)
        gss.run
      end
    end
  end

end
