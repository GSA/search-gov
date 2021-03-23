require 'spec_helper'

describe TextHelper do
  describe '#truncate_url(url, truncation_length)' do
    it 'should handle a null url' do
      expect(helper.truncate_url(nil)).to be_nil
    end
    it 'should handle a malicious url' do
      expect(helper.truncate_url('/../../../../../../../../../../../../../../../../../../../../../..//etc/passwd')).to be_nil
    end
  end
end
