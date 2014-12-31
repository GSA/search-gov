require 'spec_helper'

describe QuerySanitizer, ".sanitize" do
  context 'when UTF-8 query is malformed' do
    before do
      Sanitize.stub(:clean).and_raise ArgumentError
    end

    it 'should gracefully handle it' do
      QuerySanitizer.sanitize('bad query').should be_nil
    end
  end
end