require 'spec_helper'

describe LinkPopularity, ".popularity_for(url, days_back)" do
  context 'when days_back logstash indexes does not exist' do
    before do
      allow(ES.client_reader).to receive(:count).and_raise(Elasticsearch::Transport::Transport::Errors::NotFound)
    end

    it 'should return a default popularity of 1.0' do
      expect(LinkPopularity.popularity_for("http://www.gov.gov/someurl.html", 7)).to eq(1.0)
    end
  end
end

