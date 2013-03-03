require 'spec_helper'

describe GeoipLookup do
  describe '.lookup(ip)' do
    it "should return the geoip info for the IP address" do
      GeoipLookup.lookup('216.102.95.101').region_name.should == 'CA'
    end
  end
end