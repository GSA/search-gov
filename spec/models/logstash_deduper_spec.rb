require 'spec_helper'

describe LogstashDeduper, ".perform" do

  it_behaves_like 'a ResqueJobStats job'

  describe '.perform' do
    before do
      cursor = JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/logstash/scroll_cursor.json"))
      scroll_1 = JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/logstash/scroll_1.json"))
      scroll_2 = JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/logstash/scroll_2.json"))
      scroll_3 = JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/logstash/scroll_3.json"))
      expect(ES::client_reader).to receive(:search).with(index: 'logstash-2015.08.26', type: "search", scroll: '5m',
                                                     size: LogstashDeduper::SCROLL_SIZE, search_type: :scan).and_return cursor
      expect(ES::client_reader).to receive(:scroll).with(scroll_id: 'c2NhbjsxOzE3NDcwMjc0OmVRMFNETWNtUnltN0xjd3dWNEFpVUE7MTt0b3RhbF9oaXRzOjE1MzIzMjc7', scroll: '5m').and_return scroll_1, scroll_2, scroll_3
    end

    it 'deletes the dupes' do
      expect(ES::client_reader).to receive(:bulk).with(body: [{ :delete => { :_index => "logstash-2015.08.26", :_type => "search", :_id => "abcde" } },
                                                          { :delete => { :_index => "logstash-2015.08.26", :_type => "search", :_id => "copy1" } },
                                                          { :delete => { :_index => "logstash-2015.08.26", :_type => "search", :_id => "copy2" } },
                                                          { :delete => { :_index => "logstash-2015.08.26", :_type => "search", :_id => "copy3" } },
                                                          { :delete => { :_index => "logstash-2015.08.26", :_type => "search", :_id => "copy4" } },
                                                          { :delete => { :_index => "logstash-2015.08.26", :_type => "search", :_id => "copy5" } }])
      LogstashDeduper.perform('2015.08.26')
    end
  end
end
