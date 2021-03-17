require 'spec_helper'

describe Tika do
  describe '#get_recursive_metadata' do
    let(:file) { open_fixture_file('/pdf/test.pdf') }

    it 'extracts the metadata & content of the files' do
      expect(described_class.get_recursive_metadata(file).first['X-TIKA:content']).
        to match(/This is my content./)
    end

    context 'when something goes boom' do
      before do
        stub_request(:post, %r(rmeta)).to_return(status: 422)
      end

      it 'raises an error' do
        expect{ described_class.get_recursive_metadata(file) }.
          to raise_error(TikaError)
      end
    end
  end
end
