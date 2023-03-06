# frozen_string_literal: true

require 'spec_helper'

describe SearchImpression do
  describe '.log' do
    let(:request) do
      instance_double(ActionDispatch::Request,
                      remote_ip: '1.2.3.4',
                      url: 'http://www.gov.gov/',
                      referer: 'http://www.gov.gov/ref',
                      user_agent: 'whatevs',
                      headers: {})
    end
    let(:search) do
      double(Search,
             modules: ['BWEB'],
             diagnostics: { AWEB: { snap: 'judgement' } })
    end
    let(:params) { { 'query' => 'yep' } }
    let(:time) { Time.now }

    before do
      allow(Time).to receive(:now).and_return(time)
      allow(Rails.logger).to receive(:info)

      described_class.log(search, 'web', params, request)
    end

    context 'with regular params' do
      it 'has the single expected log line' do
        expect(Rails.logger).to have_received(:info).once
        expect(Rails.logger).to have_received(:info).with(
          '[Search Impression] {"clientip":"1.2.3.4",' \
          '"request":"http://www.gov.gov/",' \
          '"referrer":"http://www.gov.gov/ref",' \
          '"user_agent":"whatevs","diagnostics":' \
          '[{"snap":"judgement","module":"AWEB"}],' \
          "\"time\":\"#{time.to_fs(:db)}\"," \
          '"vertical":"web","modules":"BWEB",' \
          '"params":{"query":"yep"}}'
        )
      end
    end

    context 'with routed query module and empty diagnostics' do
      let(:search) { double(Search, modules: ['QRTD'], diagnostics: {}) }

      it 'has the expected log line parts' do
        expect(Rails.logger).to have_received(:info).with(
          include('"modules":"QRTD"', '"diagnostics":[]')
        )
      end
    end

    context 'params contains key with period' do
      let(:params) { { 'query' => 'yep', 'bar.blat' => 'nope' } }

      it 'omits that parameter' do
        expect(Rails.logger).to have_received(:info).with(
          include('"params":{"query":"yep"}')
        )
      end
    end

    context 'headers contains X-Original-Request header' do
      let(:request) do
        instance_double(ActionDispatch::Request,
                        remote_ip: '1.2.3.4',
                        url: 'http://www.gov.gov/',
                        referer: 'http://www.gov.gov/ref',
                        user_agent: 'whatevs',
                        headers: { 'X-Original-Request' => 'http://test.gov' })
      end

      it 'should log two lines, the original-request header and the search impression' do
        expect(Rails.logger).to have_received(:info).twice
        expect(Rails.logger).to have_received(:info).with(
          '[X-Original-Request] ("http://test.gov")'
        )
        expect(Rails.logger).to have_received(:info).with(
          include('[Search Impression]', '"request":"http://test.gov"')
        )
      end
    end

    context 'when the search includes sensitive information' do
      let(:sensitive_info) { '123-45-6789' }
      let(:params) { { 'query' => sensitive_info } }
      let(:request) do
        instance_double(ActionDispatch::Request,
                        remote_ip: '1.2.3.4',
                        url: "http://www.gov.gov/search?query=#{sensitive_info}&utm_x=123456789",
                        referer: "http://www.gov.gov/?query=foo+#{sensitive_info}+bar",
                        user_agent: 'Mozilla 123456789',
                        headers: {})
      end

      it 'does not log the sensitive information' do
        expect(Rails.logger).not_to have_received(:info).with(/123-45-6789/)
      end

      it 'specifies what was redacted' do
        expect(Rails.logger).to have_received(:info).with(/REDACTED_SSN/)
      end

      it 'logs non-sensitive information that happens to match sensitive patterns' do
        expect(Rails.logger).to have_received(:info).with(/utm_x=123456789/)
        expect(Rails.logger).to have_received(:info).with(/Mozilla 123456789/)
      end
    end
  end
end
