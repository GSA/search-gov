# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Elasticsearch Transport URL construction' do
  describe 'Connection#full_url' do
    def build_connection(host_opts)
      Elasticsearch::Transport::Transport::Connections::Connection.new(host: host_opts)
    end

    it 'constructs a basic URL without double slashes' do
      c = build_connection(protocol: 'https', host: 'localhost', port: 9200)
      expect(c.full_url('_search', {})).to eq('https://localhost:9200/_search')
    end

    it 'does not produce double slashes when host path is /' do
      c = build_connection(protocol: 'https', host: 'localhost', port: 443, path: '/')
      expect(c.full_url('_alias/test', {})).to eq('https://localhost:443/_alias/test')
    end

    it 'does not produce double slashes for empty path with host path of /' do
      c = build_connection(protocol: 'https', host: 'localhost', port: 443, path: '/')
      expect(c.full_url('', {})).to eq('https://localhost:443/')
    end

    it 'does not produce double slashes when host path is nil' do
      c = build_connection(protocol: 'https', host: 'localhost', port: 443, path: nil)
      expect(c.full_url('', {})).to eq('https://localhost:443/')
    end

    it 'does not produce double slashes when host path is empty string' do
      c = build_connection(protocol: 'https', host: 'localhost', port: 443, path: '')
      expect(c.full_url('', {})).to eq('https://localhost:443/')
    end

    it 'preserves a valid sub-path' do
      c = build_connection(protocol: 'https', host: 'localhost', port: 443, path: '/api')
      expect(c.full_url('_search', {})).to eq('https://localhost:443/api/_search')
    end

    it 'strips trailing slash from host sub-path' do
      c = build_connection(protocol: 'https', host: 'localhost', port: 443, path: '/api/')
      expect(c.full_url('_search', {})).to eq('https://localhost:443/api/_search')
    end

    it 'does not produce double slashes when API path is "/" (e.g. NewRelic cluster name check)' do
      c = build_connection(protocol: 'https', host: 'localhost', port: 443, path: nil)
      expect(c.full_url('/', {})).to eq('https://localhost:443/')
    end

    it 'does not produce double slashes when API path is "/" with empty host path' do
      c = build_connection(protocol: 'https', host: 'localhost', port: 443, path: '')
      expect(c.full_url('/', {})).to eq('https://localhost:443/')
    end

    it 'does not produce double slashes when API path is "/" with host path "/"' do
      c = build_connection(protocol: 'https', host: 'localhost', port: 443, path: '/')
      expect(c.full_url('/', {})).to eq('https://localhost:443/')
    end
  end

  describe 'Client#__parse_host' do
    def parse_host(url)
      client = Elasticsearch::Transport::Client.new(hosts: [url])
      client.transport.hosts.first
    end

    it 'sets path to nil for URL without explicit path' do
      host = parse_host('https://localhost:9200')
      expect(host[:path]).to be_nil
    end

    it 'sets path to nil for URL with only trailing slash' do
      host = parse_host('https://localhost:9200/')
      expect(host[:path]).to be_nil
    end

    it 'preserves a non-empty path' do
      host = parse_host('https://localhost:9200/api')
      expect(host[:path]).to eq('/api')
    end

    it 'strips trailing slash from a sub-path' do
      host = parse_host('https://localhost:9200/api/')
      expect(host[:path]).to eq('/api')
    end
  end
end
