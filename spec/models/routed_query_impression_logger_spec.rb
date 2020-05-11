# frozen_string_literal: true

require 'spec_helper'

describe RoutedQueryImpressionLogger do
  let!(:mock_search) do
    instance_double(RoutedQueryImpressionLogger::QueryRoutedSearch,
                    modules: ['QRTD'],
                    diagnostics: {})
  end
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:mock_request) do
    double('request',
           remote_ip: '1.2.3.4',
           url: 'http://www.gov.gov/',
           referer: 'http://www.gov.gov/ref',
           user_agent: 'whatevs',
           headers: {})
  end

  before do
    allow(RoutedQueryImpressionLogger::QueryRoutedSearch).to receive(:new).with(
      ['QRTD'],
      {}
    ).and_return(mock_search)
  end

  describe '.log' do
    it 'sets up the right params to log a search impression' do
      allow(SearchImpression).to receive(:log)

      RoutedQueryImpressionLogger.log(affiliates(:basic_affiliate),
                                      'example of a routed query',
                                      mock_request)

      expect(SearchImpression).to have_received(:log).with(
        mock_search,
        :web,
        { affiliate: 'nps.gov', query: 'example of a routed query' },
        mock_request
      )
    end
  end
end
