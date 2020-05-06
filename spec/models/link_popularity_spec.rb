require 'spec_helper'

describe LinkPopularity do
  describe '.popularity_for' do
    subject(:popularity_for) do
      LinkPopularity.popularity_for('http://www.gov.gov/someurl.html', 7)
    end

    context 'when clicks have occurred' do
      let(:click_count) { 50 }

      before do
        allow(ES::ELK.client_reader).to receive(:count).
          and_return( 'count' => click_count )
      end

      it 'returns the base 10 log of the click count' do
        expect(popularity_for).to eq(1.6989700043360187)
      end

      context 'when the base 10 log of the click count is < 1' do
        let(:click_count) { 5 }

        it { is_expected.to eq(1.0) }
      end
    end

    context 'when days_back logstash indexes does not exist' do
      before do
        allow(ES::ELK.client_reader).to receive(:count).
          and_raise(Elasticsearch::Transport::Transport::Errors::NotFound)
      end

      it 'returns a default popularity of 1.0' do
        expect(popularity_for).to eq(1.0)
      end
    end
  end
end
