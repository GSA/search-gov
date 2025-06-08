# frozen_string_literal: true

describe BulkAffiliateAddUploader do
  let(:filename) { 'add_test.csv' }
  let(:email_address) { 'test@example.com' }
  let(:csv_content) { "" }
  let(:file_path) { StringIO.new(csv_content) }
  let(:uploader) { described_class.new(filename, file_path, email_address) }
  let(:logger_double) { instance_double(ActiveSupport::Logger, warn: nil, error: nil) }

  before do
    allow(uploader).to receive(:logger).and_return(logger_double)
    allow(Rails).to receive(:logger).and_return(logger_double)
    allow(Affiliate).to receive(:exists?).and_return(false)
  end

  describe '#parse_file' do
    subject(:results) { uploader.parse_file }

    context 'when the file contains only valid affiliate names' do
      let(:csv_content) do
        <<~CSV
          Affiliate1
          Affiliate2
          Affiliate3
        CSV
      end

      before do
        allow(Affiliate).to receive(:exists?).with(name: 'Affiliate1').and_return(true)
        allow(Affiliate).to receive(:exists?).with(name: 'Affiliate2').and_return(true)
        allow(Affiliate).to receive(:exists?).with(name: 'Affiliate3').and_return(true)
      end

      it 'processes all rows' do
        expect(results.processed_count).to eq(3)
      end

      it 'identifies all affiliate names as valid' do
        expect(results.valid_affiliate_ids).to contain_exactly('Affiliate1', 'Affiliate2', 'Affiliate3')
      end

      it 'reports no failures' do
        expect(results.failed_count).to eq(0)
        expect(results.error_details).to be_empty
        expect(results.general_errors).to be_empty
      end

      it 'returns a success summary message' do
        expect(results.summary_message).to eq("File parsed successfully. Found 3 valid ID(s). Deletion job proceeding. Check email for final results.")
      end
    end

    context 'when the file contains invalid affiliate names' do
      let(:csv_content) do
        <<~CSV
          NonExistentAffiliate
          ValidAffiliate
          AnotherInvalid
        CSV
      end

      before do
        allow(Affiliate).to receive(:exists?).with(name: 'NonExistentAffiliate').and_return(false)
        allow(Affiliate).to receive(:exists?).with(name: 'ValidAffiliate').and_return(true)
        allow(Affiliate).to receive(:exists?).with(name: 'AnotherInvalid').and_return(false)
      end

      it 'processes all rows' do
        expect(results.processed_count).to eq(3)
      end

      it 'identifies only the valid affiliate names' do
        expect(results.valid_affiliate_ids).to contain_exactly('ValidAffiliate')
      end

      it 'reports failures for invalid affiliate names' do
        expect(results.failed_count).to eq(2)
        expect(results.error_details).to contain_exactly(
                                           { identifier: 'NonExistentAffiliate', error: 'Affiliate name not found.' },
                                           { identifier: 'AnotherInvalid', error: 'Affiliate name not found.' }
                                         )
        expect(results.general_errors).to be_empty
      end

      it 'logs warnings for skipped invalid rows' do
        results
        expect(logger_double).to have_received(:warn).with(/Skipping row with invalid Affiliate name 'NonExistentAffiliate'/).once
        expect(logger_double).to have_received(:warn).with(/Skipping row with invalid Affiliate name 'AnotherInvalid'/).once
      end

      it 'returns a partial success summary message' do
        expect(results.summary_message).to eq("File parsing partially completed. 1 valid ID(s) found, 2 row(s) had errors. Deletion job proceeding. Check email for final results.")
      end
    end

    context 'when the file contains blank rows or rows with missing affiliate names' do
      let(:csv_content) do
        <<~CSV.chomp
          Affiliate1

          Affiliate3
          ""
          ,
        CSV
      end

      before do
        allow(Affiliate).to receive(:exists?).with(name: 'Affiliate1').and_return(true)
        allow(Affiliate).to receive(:exists?).with(name: 'Affiliate3').and_return(true)
      end

      it 'identifies only the valid affiliate names' do
        expect(results.valid_affiliate_ids).to contain_exactly('Affiliate1', 'Affiliate3')
      end

      it 'reports failures for rows without valid affiliate names' do
        expect(results.failed_count).to eq(3)
        expect(results.error_details).to contain_exactly(
                                           { identifier: 'N/A', error: 'Row contained no Affiliate name.' },
                                           { identifier: 'N/A', error: 'Row contained no Affiliate name.' },
                                           { identifier: 'N/A', error: 'Row contained no Affiliate name.' }
                                         )
        expect(results.general_errors).to be_empty
      end

      it 'logs warnings for skipped blank rows' do
        results
        expect(logger_double).to have_received(:warn).exactly(3).times
      end

      it 'returns a partial success summary message' do
        expect(results.summary_message).to eq("File parsing partially completed. 2 valid ID(s) found, 3 row(s) had errors. Deletion job proceeding. Check email for final results.")
      end
    end

    context 'when the file is empty' do
      let(:csv_content) { "" }

      it 'processes zero rows' do
        expect(results.processed_count).to eq(0)
      end

      it 'identifies no valid affiliate names' do
        expect(results.valid_affiliate_ids).to be_empty
      end

      it 'reports no failures' do
        expect(results.failed_count).to eq(0)
        expect(results.error_details).to be_empty
      end

      it 'adds a general error for no data rows' do
        expect(results.general_errors).to contain_exactly('No data rows found in the CSV file.')
      end

      it 'returns a general error summary message' do
        expect(results.summary_message).to eq("File parsing failed: No data rows found in the CSV file.")
      end
    end

    context 'when an unexpected error occurs during processing' do
      let(:csv_content) { "Affiliate1\nAffiliate2" }

      before do
        allow(Affiliate).to receive(:exists?).with(name: 'Affiliate1').and_return(true)
        allow(Affiliate).to receive(:exists?).with(name: 'Affiliate2').and_raise(StandardError, 'Unexpected error')
      end

      it 'processes all rows attempted before the error' do
        expect(results.processed_count).to eq(2)
      end

      it 'captures valid affiliate names processed before the error' do
        expect(results.valid_affiliate_ids).to contain_exactly('Affiliate1')
      end

      it 'reports a failure for the row where the error occurred' do
        expect(results.failed_count).to eq(1)
        expect(results.error_details).to contain_exactly(
                                           { identifier: 'Affiliate2', error: 'Error processing row: Unexpected error' }
                                         )
        expect(results.general_errors).to be_empty
      end

      it 'logs the row processing error' do
        results
        expect(logger_double).to have_received(:error).with(/Row: \["Affiliate2"\] - Error: Unexpected error/)
      end

      it 'returns a partial success summary message' do
        expect(results.summary_message).to eq("File parsing partially completed. 1 valid ID(s) found, 1 row(s) had errors. Deletion job proceeding. Check email for final results.")
      end
    end
  end
end
