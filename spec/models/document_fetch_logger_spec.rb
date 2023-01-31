require 'spec_helper'

describe DocumentFetchLogger do
  subject { described_class.new(url, type, attributes) }

  let(:url) { 'http://www.example.com/foo.html' }
  let(:type) { 'rss_feed' }
  let(:attributes) { { } }

  describe '.new' do
    it 'retains the url, type, and attributes given' do
      expect(subject.url).to eq(url)
      expect(subject.type).to eq(type)
      expect(subject.attributes).to eq(attributes)
    end
  end

  describe '#log' do
    before { allow(Rails.logger).to receive(:info) }
    before { travel_to(Time.gm(1997, 8, 4, 5, 14)) }
    after { travel_back }

    context 'when no additional attributes are provided' do
      it 'logs just the domain, time, type, and url' do
        expect(Rails.logger).to receive(:info).with('[Document Fetch] {"domain":"www.example.com","time":"1997-08-04 05:14:00","type":"rss_feed","url":"http://www.example.com/foo.html"}')
        subject.log
      end
    end

    context 'when additional attributes are provided' do
      let(:attributes) { { foo: 'bar', baz: 'quux' } }

      it 'logs the domain, time, type, and url plus all the attributes' do
        expect(Rails.logger).to receive(:info).with('[Document Fetch] {"foo":"bar","baz":"quux","domain":"www.example.com","time":"1997-08-04 05:14:00","type":"rss_feed","url":"http://www.example.com/foo.html"}')
        subject.log
      end
    end
  end
end
