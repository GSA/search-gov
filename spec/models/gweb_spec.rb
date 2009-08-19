require "#{File.dirname(__FILE__)}/../spec_helper"
describe Gweb do

  describe "#run" do
    context "when affiliate has domains specified" do
      it "should use domains in query string" do
        affiliate = Affiliate.new(:domains => %w(foo.com bar.com).join("\n"))
        uriresult = URI::parse("http://127.0.0.1/noop")
        gweb = Gweb.new(:query => "government", :affiliate => affiliate, :page => 0)
        URI.should_receive(:parse).with("http://www.google.com/uds/GwebSearch?context=0&hl=en&lstkp=0&q=government%20site:foo.com%20OR%20site:bar.com&rsz=large&start=0&v=0.1").and_return(uriresult)
        gweb.run
      end
    end

    context "when affiliate has no domains specified" do
      it "should use just query string" do
        affiliate = Affiliate.new
        uriresult = URI::parse("http://127.0.0.1/noop")
        gweb = Gweb.new(:query => "government", :affiliate => affiliate, :page => 0)
        URI.should_receive(:parse).with("http://www.google.com/uds/GwebSearch?context=0&cx=012983105564958037848:xhukbbvbwi0&hl=en&lstkp=0&q=government&rsz=large&start=0&v=0.1").and_return(uriresult)
        gweb.run
      end
    end

    context "when affiliate is nil" do
      it "should use just query string" do
        uriresult = URI::parse("http://127.0.0.1/noop")
        gweb = Gweb.new(:query => "government", :affiliate => nil, :page => 0)
        URI.should_receive(:parse).with("http://www.google.com/uds/GwebSearch?context=0&cx=012983105564958037848:xhukbbvbwi0&hl=en&lstkp=0&q=government&rsz=large&start=0&v=0.1").and_return(uriresult)
        gweb.run
      end
    end
  end

end
