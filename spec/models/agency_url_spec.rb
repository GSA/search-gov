require 'spec/spec_helper'

describe AgencyUrl do
  it { should validate_presence_of :url }
  it { should validate_presence_of :locale }

  describe "#to_label" do
    it "returns url" do
      AgencyUrl.new(:url => 'http://search.usa.gov').to_label.should == 'http://search.usa.gov'
    end
  end
end
