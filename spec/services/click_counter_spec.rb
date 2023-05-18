# frozen_string_literal: true

describe ClickCounter do
  let(:counter) { described_class.new(domain: 'agency.gov') }

  describe '#update_click_counts' do
    subject(:update_click_counts) { counter.update_click_counts }

    context 'when clicks are available' do
      let(:url) { 'https://agency.gov/' }

      before do
        allow(counter).to receive(:statistically_significant_clicks).
          and_return([[url, 1000]])
      end

      context 'when a SearchgovUrl record exists for that URL' do
        let(:searchgov_url) { SearchgovUrl.create!(url: url) }

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
        before { allow(Rails.logger).to receive(:error) }

        it 'logs the missing URL' do
          update_click_counts
          expect(Rails.logger).to have_received(:error).
            with('SearchgovUrl not found for clicked URL: https://agency.gov/')
        end
      end

      context 'when the URL has not been indexed' do
        before do
          SearchgovUrl.create!(url: url)
          allow(I14yDocument).to receive(:update).
            and_raise(I14yDocument::I14yDocumentError, 'fail')
        end

        it 'logs the unindexed URL' do
          expect(Rails.logger).to receive(:error).with(
            'Unable to update I14yDocument click_count for https://agency.gov/: fail'
          )
          update_click_counts
        end
      end
    end
  end

  describe '#statistically_significant_clicks' do
    subject(:clicks) { counter.send(:statistically_significant_clicks) }

    before { travel_to(Time.current) }

    it "generates a query for the last month's significant clicks" do
      expect(DateRangeTopNFieldQuery).to receive(:new).
        with(nil,
             'click',
             1.month.ago,
             Time.current,
             'click_domain',
             'agency.gov',
             { field: 'params.url', size: 3_000 }).
        and_call_original
      clicks
    end

    context 'when click data is available' do
      let(:json) do
        JSON.parse(read_fixture_file('/json/rtu_dashboard/top_clicks_one_domain.json'))
      end

      before do
        allow(Es::ELK.client_reader).to receive(:search).and_return json
      end

      it 'returns the statistically significant clicks' do
        expect(clicks.last).to eq ['https://search.gov/tos.html', 1]
      end
    end
  end
end
