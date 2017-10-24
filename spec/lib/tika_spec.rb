require 'spec_helper'

describe Tika do
  describe '#get_recursive_metadata' do
    let(:file) { open_fixture_file('/pdf/test.pdf') }

    it 'extracts the metadata & content of the files' do
      expect(Tika.get_recursive_metadata(file).first['X-TIKA:content']).
        to match(/This is my content./)
    end
  end
end
