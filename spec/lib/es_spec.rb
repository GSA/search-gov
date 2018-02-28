require 'spec_helper'

describe ES do
  describe ".client_reader" do
    it 'should use the value from the secrets.yml elasticsearch reader entry' do
      expect(ES.client_reader.transport.hosts.first[:host]).to eq(Rails.application.secrets.elasticsearch['reader'])
    end
  end

  describe ".client_writers" do
    it 'should use the value from the YAML file' do
      expect(ES.client_writers.size).to eq(Rails.application.secrets.elasticsearch['writers'].count)
      expect(ES.client_writers.first.transport.hosts.first[:host]).to eq(Rails.application.secrets.elasticsearch['writers'].first)
    end
  end
end
