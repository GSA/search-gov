# frozen_string_literal: true

require 'spec_helper'

describe ApiClick do
  let(:affiliate) { 'nps.gov' }
  subject(:click) do
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
      it { is_expected.to be_valid }
    end

    describe '#log' do
      it 'logs almost-JSON info about the click' do
        allow(Rails.logger).to receive(:info)

        click.validate #validating causes other instance variables to appear.
        click.log

        expected_log = '[Click] {"url":"http://www.fda.gov/foo.html",'\
                       '"query":"my query","client_ip":"123.123.123.123",'\
                       '"affiliate":"nps.gov","position":"7","module_code":"BWEB",'\
                       '"vertical":"web","user_agent":"mozilla","access_key":"basic_key"}'

        expect(Rails.logger).to have_received(:info).with(expected_log)
      end
    end
  end

  context 'without required params' do
    subject(:click) do
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
      it { is_expected.not_to be_valid }
    end

    describe '#errors' do
      it 'has expected errors' do
        click.validate
        expected_errors = ["Query can't be blank",
                           "Position can't be blank",
                           "Module code can't be blank",
                           "Client ip can't be blank",
                           "User agent can't be blank",
                           "Url can't be blank",
                           "Affiliate can't be blank",
                           "Access key can't be blank"]
        expect(click.errors.full_messages).to eq expected_errors
      end
    end
  end

  context 'with inactive affiliate' do
    let(:affiliate) { 'inactive_affiliate' }

    it 'returns a 400 with an invalid affiliate message' do
      click.validate
      expect(click.errors.full_messages).to eq ['Affiliate is invalid']
    end
  end

  context "with an affiliate that doesn't exist" do
    let(:affiliate) { 'not_an_affiliate' }

    it 'returns a 400 with an invalid affiliate message' do
      click.validate
      expect(click.errors.full_messages).to eq ['Affiliate is invalid']
    end
  end
end
