require 'spec_helper'

describe QuerySanitizer, ".sanitize" do
  context 'when UTF-8 query is malformed' do
    before do
      allow(Sanitize).to receive(:clean).and_raise ArgumentError
    end

    it 'should gracefully handle it' do
      expect(QuerySanitizer.sanitize('bad query')).to be_nil
    end
  end
end