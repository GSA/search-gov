require 'spec_helper'

describe FaradayResponseBodyRashify do
  describe '.process_response' do
    context 'when the body is a Hash' do
      let(:hash_body) { { body: {"foo"=>"bar"} }  }
      let(:response) { Faraday::Response.new(Hashie::Rash.new( hash_body )) }
      it 'parses the body' do
        described_class.process_response(response)
        expect(response.env.body).to eq( {"foo"=>"bar"} )
      end
    end

    context 'when the body is a String' do
      let(:string_body) { {'body'=>'{"foo":"bar"}'} }
      let(:response) { Faraday::Response.new(Hashie::Rash.new( string_body )) }
      it 'parses the body' do
        described_class.process_response(response)
        expect(response.env.body).to eq( {"foo"=>"bar"} )
      end
    end
  end

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
