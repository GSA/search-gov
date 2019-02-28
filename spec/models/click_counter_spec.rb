require 'spec_helper'

describe ClickCounter do
  let(:counter) { ClickCounter.new(domain: 'agency.gov') }

  describe '#update_click_counts' do
    subject(:update_click_counts) { counter.update_click_counts }

    context 'when clicks are available' do
      let(:url) { 'http://agency.gov/' }

      before do
        allow(counter).to receive(:statistically_significant_clicks).
          and_return([[url, 1000]])
      end

      context 'when a SearchgovUrl record exists for that URL' do
        let!(:searchgov_url) { SearchgovUrl.create!(url: url) }

        it 'updates the click counts for the popular URLs' do
          expect(I14yDocument).to receive(:update).with(
            document_id: searchgov_url.document_id,
            click_count: 1000,
            handle: 'searchgov'
          )
          update_click_counts
        end
      end

      context 'when no SearchgovUrl record exists for that URL' do
        it 'logs the missing URL' do
          expect(Rails.logger).to receive(:error).
            with('SearchgovUrl not found for clicked URL: http://agency.gov/')
          update_click_counts
        end
      end
    end
  end

  describe '#statistically_significant_clicks' do
    subject(:clicks) { counter.send(:statistically_significant_clicks) }

    before { Timecop.freeze }

    after { Timecop.return }

    it "generates a query for the last month's significant clicks" do
      expect(DateRangeTopNFieldQuery).to receive(:new).
        with(nil,
             1.month.ago,
             Time.now,
             'click_domain',
             'agency.gov',
             { field: 'params.url', size: 0 }).
        and_call_original
      clicks
    end

    context 'when click data is available' do
      let(:json) do
        JSON.parse(read_fixture_file('/json/rtu_dashboard/top_clicks_one_domain.json'))
      end

      before do
        allow(ES::ELK.client_reader).to receive(:search).and_return json
      end

      it 'returns the statistically significant clicks' do
        expect(clicks.last).to eq ['https://search.gov/manual/add-site.html', 1]
      end
    end
  end
end
