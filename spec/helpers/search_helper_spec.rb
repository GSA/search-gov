require "#{File.dirname(__FILE__)}/../spec_helper"

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

  describe "#shorten_url" do
    context "when URL is more than 30 chars long and has at least one sublevel specified" do
      before do
        @url = "http://www.foo.com/this/goes/on/and/on/and/on/and/on/and/ends/with/XXXX.html?q=1&a=2&b=3"
      end

      it "should replace everything between the hostname and the document with ellipses and remove params" do
        helper.send(:shorten_url, @url).should == "http://www.foo.com/.../XXXX.html"
      end
    end
  end

end