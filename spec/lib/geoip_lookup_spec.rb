require 'spec_helper'

describe GeoipLookup do
  describe '.lookup(ip)' do
    context 'success' do
      it "returns the geoip info for the IP address" do
        GeoipLookup.lookup('216.102.95.101').region_name.should == 'CA'
      end
    end

    context 'failure' do
      before do
        IPSocket.stub(:getaddress).and_raise(SocketError)
      end

      it "returns nil" do
        GeoipLookup.lookup('localhost').should be_nil
      end
    end
  end
end