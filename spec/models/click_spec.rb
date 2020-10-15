# frozen_string_literal: true

require 'spec_helper'

describe Click do
  let(:url) { 'http://www.fda.gov/foo.html' }
  let(:ip) { '0.0.0.0' }
  let(:position) { '7' }
  let(:module_code) { 'BWEB' }
  let(:query) { 'my query' }
  let(:params) do
    {
      url: url,
      query: query,
      client_ip: ip,
      affiliate: 'nps.gov',
      position: position,
      module_code: module_code,
      vertical: 'web',
      user_agent: 'mozilla',
      referrer: 'http://www.fda.gov/referrer'
    }
  end

  subject(:click) { described_class.new(params) }

  context 'with required params' do
    describe '#valid?' do
      it { is_expected.to be_valid }
    end

    describe '#log' do
      let(:click_json) do
        {
          clientip: '0.0.0.0',
          referrer: 'http://www.fda.gov/referrer',
          user_agent: 'mozilla',
          time: '2020-01-01 00:00:00',
          vertical: 'web',
          modules: 'BWEB',
          click_domain: 'www.fda.gov',
          params: {
            url: 'http://www.fda.gov/foo.html',
            affiliate: 'nps.gov',
            query: 'my query',
            position: '7'
          }
        }.to_json
      end

      before do
        allow(Rails.logger).to receive(:info)
        travel_to(Time.utc(2020, 1, 1))
      end

      after { travel_back }

      it 'logs almost-JSON info about the click' do
        click.log

        expect(Rails.logger).to have_received(:info).with("[Click] #{click_json}")
      end

      context 'when the URL is encoded' do
        let(:url) { 'https://search.gov/%28%3A%7C%29'  }

        it 'logs the escaped URL' do
          click.log
          expect(Rails.logger).to have_received(:info).with(%r{https://search.gov/(:|)})
        end
      end

      # The different search engines use different formatters, but for simplicity's
      # sake, we simply downcase the query that we log for logstash
      context 'when the URL contains capital letters' do
        let(:query) { 'DOWNCASE ME' }

        it 'downcases the query' do
          click.log
          expect(Rails.logger).to have_received(:info).with(/downcase me/)
        end
      end
    end
  end

  context 'without required params' do
    let(:params) do
      {
        url: nil,
        query: nil,
        client_ip: nil,
        affiliate: nil,
        position: nil,
        module_code: nil,
        vertical: nil,
        user_agent: nil
      }
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
                           "Url can't be blank"]
        expect(click.errors.full_messages).to eq expected_errors
      end
    end
  end

  describe '#url_encoding_validation' do
    context 'with invalid utf-8 in the url' do
      # https://cm-jira.usa.gov/browse/SRCHAR-415
      let(:url) { "https://example.com/wymiana teflon\xF3w" }

      it 'has expected errors' do
        click.validate
        expect(click.errors.full_messages).to eq ['Url is not a valid format']
      end

      context 'when the unencoded URL contains invalid characters' do
        let(:url) { "https://example.com/wymiana+teflon%F3w" }

        it 'has expected errors' do
          click.validate
          expect(click.errors.full_messages).to eq ['Url is not a valid format']
        end
      end
    end

    context 'with malformed urls' do
      let(:url) { 'something is wrong' }

      it 'has expected errors' do
        click.validate
        expect(click.errors.full_messages).to eq ['Url is not a valid format']
      end
    end
  end

  describe '.valid_ip?' do
    context 'with valid ip4' do
      let(:ip) { '123.123.123.123' }

      it { is_expected.to be_valid }
    end

    context 'with valid ip6' do
      let(:ip) { '2600:1f18:f88:4313:6df7:f986:f915:78d6' } # gsa.gov?

      it { is_expected.to be_valid }
    end

    context 'with invalid ip address' do
      let(:ip) { 'bad_ip_address' }

      it { is_expected.not_to be_valid }

      it 'has expected errors' do
        click.validate
        expect(click.errors.full_messages).to eq ['Client ip is invalid']
      end
    end
  end

  describe 'only allow positive positions' do
    context 'with negative number' do
      let(:position) { '-4' }

      it { is_expected.not_to be_valid }

      it 'has expected errors' do
        click.validate
        error_msg = ['Position must be greater than or equal to 0']
        expect(click.errors.full_messages).to eq error_msg
      end
    end

    context 'with a decimal' do
      let(:position) { '1.87897' }

      it { is_expected.not_to be_valid }

      it 'has expected errors' do
        click.validate
        expect(click.errors.full_messages).to eq ['Position must be an integer']
      end
    end

    context 'with a word' do
      let(:position) { 'second' }

      it { is_expected.not_to be_valid }

      it 'has expected errors' do
        click.validate
        error_msg = ['Position is not a number']
        expect(click.errors.full_messages).to eq error_msg
      end
    end
  end

  describe 'validate module code' do
    context 'not in official list of codes' do
      let(:module_code) { 'whatever' }

      it { is_expected.not_to be_valid }

      it 'has expected errors' do
        click.validate
        error_msg = ['Module code whatever is not a valid module']
        expect(click.errors.full_messages).to eq error_msg
      end
    end
  end
end
