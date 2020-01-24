require 'spec_helper'

describe LogstashDeduper do

  it_behaves_like 'a ResqueJobStats job'

  describe '.perform' do
    context 'when duplicates exist' do
      let(:search_args) do
        {
          index: 'logstash-2015.08.26',
          type: 'search',
          scroll: '5m',
          size: LogstashDeduper::SCROLL_SIZE,
          sort: '_doc'
        }
      end
      let(:cursor) { JSON.parse(read_fixture_file('/json/logstash/scroll_cursor.json')) }
      let(:scroll_1) { JSON.parse(read_fixture_file('/json/logstash/scroll_1.json')) }
      let(:scroll_2) { JSON.parse(read_fixture_file('/json/logstash/scroll_2.json')) }
      let(:scroll_3) { JSON.parse(read_fixture_file('/json/logstash/scroll_3.json')) }
      let(:scroll_id) do
        'c2NhbjsxOzE3NDcwMjc0OmVRMFNETWNtUnltN0xjd3dWNEFpVUE7MTt0b3RhbF9oaXRzOjE1MzIzMjc7'
      end

      before do
        allow(ES::ELK.client_reader).to receive(:search).
          with(search_args).and_return cursor
        allow(ES::ELK.client_reader).to receive(:scroll).
          with(scroll_id: scroll_id, scroll: '5m').
          and_return(scroll_1, scroll_2, scroll_3)
      end

      it 'deletes the dupes' do
        expect(ES::ELK.client_reader).to receive(:bulk).
          with(
            body: [
              { delete: { _index: 'logstash-2015.08.26', _type: 'search', _id: 'abcde' } },
              { delete: { _index: 'logstash-2015.08.26', _type: 'search', _id: 'copy1' } },
              { delete: { _index: 'logstash-2015.08.26', _type: 'search', _id: 'copy2' } },
              { delete: { _index: 'logstash-2015.08.26', _type: 'search', _id: 'copy3' } },
              { delete: { _index: 'logstash-2015.08.26', _type: 'search', _id: 'copy4' } },
              { delete: { _index: 'logstash-2015.08.26', _type: 'search', _id: 'copy5' } }
          ]
        )
        LogstashDeduper.perform('2015.08.26')
      end
    end

    it 'does not raise an error' do
      expect {
        LogstashDeduper.perform(Date.today.strftime('%Y.%m.%d'))
      }.not_to raise_error
    end
  end
end
