require 'spec_helper'

describe NewsItemsDestroyer do
  it_behaves_like 'a ResqueJobStats job'

  describe '.perform' do
    let(:batch_group) do
      [mock_model(NewsItem, id: 100),
       mock_model(NewsItem, id: 101)]
    end

    let(:ids) { [100, 101].freeze }

    it 'destroy all NewsItems' do
      allow(NewsItem).to receive_message_chain(:where, :select, :find_in_batches).and_yield(batch_group)
      expect(NewsItem).to receive(:fast_delete).with(ids)

      described_class.perform 100
    end
  end
end
