require 'spec_helper'

describe FaradayResponseBodyRashify do
  describe '.parse' do
    context 'when body is an Array of Hash' do
      it 'creates an array of Hashie::Rash' do
        parsed_body = described_class.parse [{ foo: 'bar' }]
        parsed_body.first.should be_an_instance_of(::Hashie::Rash)
        parsed_body.first.foo.should eq('bar')
      end
    end

    context 'when body is a String' do
      it 'returns the string' do
        described_class.parse('body string').should eq('body string')
      end
    end
  end
end
