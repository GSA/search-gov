require 'spec_helper'

describe GeoipExtensions do
  describe GeoIP::City do
    let(:city) { GeoipLookup.lookup('159.142.55.255') }

    describe '.location_name' do
      subject(:location_name) { city.location_name }

      it { is_expected.to eq 'Washington, District of Columbia, United States' }

      context 'when the location is international' do
        let(:city) { GeoipLookup.lookup('85.214.132.117') }

        it { is_expected.to eq "Berlin, Berlin, Germany" }
      end

      context 'when the city and region are nil' do
        let(:city) { GeoipLookup.lookup('197.156.65.234') }

        it { is_expected.to eq 'Ethiopia' }
      end
    end
  end
end
