require 'spec_helper'

describe TextHelper do
  describe "#truncate_url(url, truncation_length)" do
    it "should handle a null url" do
      helper.truncate_url(nil).should be_nil
    end
    it "should handle a malicious url" do
      helper.truncate_url("/../../../../../../../../../../../../../../../../../../../../../..//etc/passwd").should be_nil
    end
  end
end
