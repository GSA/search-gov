# frozen_string_literal: true

require 'spec_helper'

describe ApiClick do
  let(:affiliate) { 'nps.gov' }
  let(:click) do
    described_class.new url: 'http://www.fda.gov/foo.html',
                        query: 'my query',
                        client_ip: '123.123.123.123',
                        affiliate: affiliate,
                        position: '7',
                        module_code: 'BWEB',
                        vertical: 'web',
                        user_agent: 'mozilla',
                        access_key: 'basic_key'
  end

  context 'with required params' do
    describe '#valid?' do
      it 'is valid' do
        expect(click.valid?).to be_truthy
      end
    end

    describe '#log' do
      it 'logs almost-JSON info about the click' do
        allow(Rails.logger).to receive(:info)

        click.log

        expect(Rails.logger).to have_received(:info) do |str|
          expect(str).to match(/^\[Click\] \{.*\}$/)
          expect(str).to include('"url":"http://www.fda.gov/foo.html"')
          expect(str).to include('"query":"my query"')
          expect(str).to include('"client_ip":"123.123.123.123"')
          expect(str).to include('"affiliate":"nps.gov"')
          expect(str).to include('"position":"7"')
          expect(str).to include('"module_code":"BWEB"')
          expect(str).to include('"vertical":"web"')
          expect(str).to include('"user_agent":"mozilla"')
          expect(str).to include('"access_key":"basic_key"')
        end
      end
    end
  end

  context 'without required params' do
    let(:click) do
      described_class.new url: nil,
                          query: nil,
                          client_ip: nil,
                          affiliate: nil,
                          position: nil,
                          module_code: nil,
                          vertical: nil,
                          user_agent: nil,
                          access_key: nil
    end

    describe '#valid?' do
      it 'is not valid' do
        expect(click.valid?).to be_falsey
      end
    end

    describe '#errors' do
      it 'has expected errors' do
        click.valid?

        expected_errors = ["Url can't be blank",
                           "Query can't be blank",
                           "Position can't be blank",
                           "Module code can't be blank",
                           "Client ip can't be blank",
                           "User agent can't be blank",
                           "Affiliate can't be blank",
                           "Access key can't be blank"]
        expect(click.errors.full_messages).to eq expected_errors
      end
    end
  end

  context 'with inactive affiliate' do
    let(:affiliate) { 'inactive_affiliate' }

    it 'returns a 400 with an invalid affiliate message' do
      click.valid?

      expect(click.errors.full_messages).to eq ['Affiliate is inactive']
    end
  end
end
