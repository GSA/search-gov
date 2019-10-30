require 'spec_helper'

describe ES do
  context 'when working in ES submodules' do
    let(:elk_objs) { Array.new(3, ES::ELK.client_reader) }
    let(:ci_objs) { Array.new(3, ES::ELK.client_reader) }

    describe '.client_reader' do
      it 'returns a different object in different submodules' do
        expect(ES::ELK.client_reader).to_not eq(ES::CustomIndices.client_reader)
      end

      it 'returns the same object given successive invocations' do
        2.times do |i|
          expect(elk_objs[i]).to eq(elk_objs[i+1])
          expect(ci_objs[i]).to eq(ci_objs[i+1])
        end
      end
    end

    describe '.client_writers' do
      it 'returns a different object in different submodules' do
        expect(ES::ELK.client_writers).to_not eq(ES::CustomIndices.client_writers)
      end

      it 'returns the same object given successive invocations' do
        2.times do |i|
          expect(elk_objs[i]).to eq(elk_objs[i+1])
          expect(ci_objs[i]).to eq(ci_objs[i+1])
        end
      end
    end
  end

  context 'when working in ES::ELK submodule' do
    let(:es_config) { Rails.application.secrets.analytics['elasticsearch'] }

    describe '.client_reader' do
      subject(:client_reader) { ES::ELK.client_reader }
      let(:host) { client_reader.transport.hosts.first }

      it 'uses the values from the secrets.yml analytics[elasticsearch][reader] entry' do
        expect(host[:host]).to eq(URI(es_config['reader']['host']).host)
        expect(host[:user]).to eq(es_config['reader']['user'])
      end
    end

    describe '.client_writers' do
      subject(:client_writers) { ES::ELK.client_writers }

      it 'uses the value(s) from the secrets.yml analytics[elasticsearch][writers] entry' do
        count = Rails.application.secrets.analytics['elasticsearch']['writers'].count
        expect(ES::ELK.client_writers.size).to eq(count)
        count.times do |i|
          host = ES::ELK.client_writers.first.transport.hosts[i]
          expect(host[:host]).to eq(URI(es_config['writers'][i]['host']).host)
          expect(host[:user]).to eq(es_config['writers'][i]['user'])
        end
      end

      it 'freezes the secrets' do
        client_writers
        expect(es_config['writers']).to be_frozen
      end
    end
  end

  describe 'when working in ES::CustomIndices submodule' do
    let(:es_config) { Rails.application.secrets.custom_indices['elasticsearch'] }

    describe '.client_reader' do
      let(:client) { ES::CustomIndices.client_reader }
      let(:host) { client.transport.hosts.first }

      it 'uses the values from the secrets.yml custom_indices[elasticsearch][reader] entry' do
        expect(host[:host]).to eq(URI(es_config['reader']['hosts'].first).host)
        expect(host[:user]).to eq(es_config['reader']['user'])
      end

      it_behaves_like 'an Elasticsearch client'
    end

    describe '.client_writers' do
      let(:client) { ES::CustomIndices.client_writers.first }

      it 'uses the value(s) from the secrets.yml custom_indices[elasticsearch][writers] entry' do
        count = Rails.application.secrets.custom_indices['elasticsearch']['writers'].count
        expect(ES::CustomIndices.client_writers.size).to eq(count)
        count.times do |i|
          host = client.transport.hosts[i]
          expect(host[:host]).to eq(URI(es_config['writers'][i]['hosts'].first).host)
          expect(host[:user]).to eq(es_config['writers'][i]['user'])
        end
      end

      it 'freezes the secrets' do
        ES::CustomIndices.client_writers
        expect(es_config['writers']).to be_frozen
      end

      it_behaves_like 'an Elasticsearch client'
    end
  end
end
