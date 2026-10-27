# frozen_string_literal: true

require 'spec_helper'

describe 'A user searches', js: true, vcr: { preserve_exact_body_bytes: true } do
  include_context 'when the click request is browser-based'

  context 'a searchgov site' do
    let!(:affiliate) { affiliates(:searchgov_affiliate) }

    context 'for a best bet' do
      before do
        affiliate.boosted_contents.create!(title: 'A boosted search result',
                                          description: 'An example description',
                                          url: 'http://example.com',
                                          status: 'active',
                                          publish_start_on: Date.current)

        ElasticBoostedContent.commit

        visit '/search?affiliate=searchgovaffiliate&query=boosted'
      end

      describe 'the user clicks a search result' do
        let(:click_log_lines) { [] }

        before do
          allow(Rails.logger).to receive(:info).and_wrap_original do |original, message, &block|
            click_log_lines << message if message.to_s.start_with?('[Click]')
            original.call(message, &block)
          end
        end

        it 'js sends in a click event, creating the expected log line.' do
          # Firefox cancels a pending fetch when the result click navigates away.
          page.execute_script(<<~JS)
            const originalFetch = window.fetch;
            window.fetch = (url, options = {}) => originalFetch(url, { ...options, keepalive: true });
          JS
          find('.boosted-content .result-title-link', text: 'A boosted search result').click

          Timeout.timeout(Capybara.default_max_wait_time) { sleep 0.1 while click_log_lines.empty? }

          click = JSON.parse(click_log_lines.first.delete_prefix('[Click] '))
          expect(click).to include('clientip' => '127.0.0.1',
                                   'modules' => 'BOOS',
                                   'vertical' => 'document',
                                   'user_agent' => 'test_user_agent',
                                   'referrer' => a_kind_of(String))
          expect(click['params']).to include('url' => 'http://example.com',
                                             'query' => 'boosted',
                                             'affiliate' => 'searchgovaffiliate',
                                             'position' => 1)
        end
      end
    end
  end
end
