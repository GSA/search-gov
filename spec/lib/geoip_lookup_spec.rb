require 'spec_helper'

describe GeoipLookup do
  describe '.lookup(ip)' do
    context 'success' do
      it 'returns the geoip info for the IP address' do
        expect(described_class.lookup('216.102.95.101').region_name).to eq('CA')
      end
    end

    context 'failure' do
      before do
        allow(IPSocket).to receive(:getaddress).and_raise(SocketError)
      end

      it 'returns nil' do
        expect(described_class.lookup('localhost')).to be_nil
      end
    end
  end
end