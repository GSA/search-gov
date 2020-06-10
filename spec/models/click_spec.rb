# frozen_string_literal: true

require 'spec_helper'

describe Click do
  let(:url) { 'http://www.fda.gov/foo.html' }
  let(:ip) { '0.0.0.0' }
  let(:position) { '7' }
  let(:module_code) { 'BWEB' }
  let(:params) do
    {
      url: url,
      query: 'my query',
      client_ip: ip,
      affiliate: 'nps.gov',
      position: position,
      module_code: module_code,
      vertical: 'web',
      user_agent: 'mozilla'
    }
  end
  let(:click) { described_class.new params }

  context 'with required params' do
    describe '#valid?' do
      it 'should be valid' do
        expect(click.valid?).to be_truthy
      end
    end

    describe '#log' do
      it 'should log almost-JSON info about the click' do
        expect(Rails.logger).to receive(:info) do |str|
          expect(str).to match(/^\[Click\] \{.*\}$/)
          expect(str).to include('"url":"http://www.fda.gov/foo.html"')
          expect(str).to include('"query":"my query"')
          expect(str).to include('"client_ip":"0.0.0.0"')
          expect(str).to include('"affiliate":"nps.gov"')
          expect(str).to include('"position":"7"')
          expect(str).to include('"module_code":"BWEB"')
          expect(str).to include('"vertical":"web"')
          expect(str).to include('"user_agent":"mozilla"')
        end

        click.log
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
                           "User agent can't be blank"]
        expect(click.errors.full_messages).to eq expected_errors
      end
    end
  end

  describe '#unescape_url' do
    let(:url) { 'https://search.gov/%28 %3A%7C%29' }

    it 'returns an unescaped url' do
      unescaped_url_log = '"url":"https://search.gov/(+:|)"'
      expect(Rails.logger).to receive(:info).with(include(unescaped_url_log))

      click.log
    end

    context 'with invalid utf-8 in the url' do
      # https://cm-jira.usa.gov/browse/SRCHAR-415
      let(:url) { 'https://example.com/wymiana+teflon%F3w' }

      it 'drops the unescapable url' do
        expect(click.url).to be nil
      end
    end
  end

  describe '.valid_ip?' do
    context 'with valid ip4' do
      let(:ip) { '123.123.123.123' }

      it 'is valid' do
        expect(click.send(:valid_ip?)).to be_truthy
      end
    end

    context 'with valid ip6' do
      let(:ip) { '2600:1f18:f88:4313:6df7:f986:f915:78d6' } # gsa.gov?

      it 'is valid' do
        expect(click.send(:valid_ip?)).to be_truthy
      end
    end

    context 'with invalid ip address' do
      let(:ip) { 'bad_ip_address' }

      it 'is not valid' do
        expect(click.valid?).to be_falsey
      end

      it 'has expected errors' do
        click.valid?

        expect(click.errors.full_messages).to eq ['Client ip is invalid']
      end
    end
  end

  describe 'only allow positive positions' do
    context 'with negative number' do
      let(:position) { '-4' }

      it 'is invalid' do
        expect(click.valid?).to be_falsey
        expect(click.errors.full_messages).to eq ['Position must be greater than or equal to 0']
      end
    end

    context 'with a decimal' do
      let(:position) { '1.87897' }

      it 'is invalid' do
        expect(click.valid?).to be_falsey
        expect(click.errors.full_messages).to eq ['Position must be an integer']
      end
    end

    context 'with a word' do
      let(:position) { 'second' }

      it 'is invalid' do
        expect(click.valid?).to be_falsey
        error_msg = ['Position is not a number']
        expect(click.errors.full_messages).to eq error_msg
      end
    end
  end

  describe 'validate module code' do
    context 'not in official list of codes' do
      let(:module_code) { 'whatever' }

      it 'is invalid' do
        expect(click.valid?).to be_falsey
        error_msg = ['Module code whatever is not a valid module']
        expect(click.errors.full_messages).to eq error_msg
      end
    end
  end
end
