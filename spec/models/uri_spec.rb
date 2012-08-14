require 'spec_helper'

describe URI do
  describe "#self.merge_unless_recursive(self_url, target_url)?" do
    let(:self_url) { URI.parse("http://www.foo.gov/rss-feeds/media-garbage") }
    context "when the target URL looks like it's going to create a relative self-reference" do
      let(:target_url) { URI.parse("rss-feeds/media-garbage") }
      it "should return nil" do
        URI.merge_unless_recursive(self_url, target_url).should be_nil
      end
    end

    context "when the target URL looks sane" do
      let(:target_url) { URI.parse("/rss-feeds/media-garbage2") }
      it "should return the merged URLs" do
        URI.merge_unless_recursive(self_url, target_url).should == URI.parse("http://www.foo.gov/rss-feeds/media-garbage2")
      end
    end
  end

end
