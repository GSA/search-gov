require 'spec_helper'

describe BulkAffiliateDeleteUploader, type: :service do
  let(:filename) { 'delete_test.csv' }
  let(:requesting_user_email) { 'test@example.com' }
  let(:csv_content) { "" }
  let(:file_path) { StringIO.new(csv_content) }
  let(:uploader) { described_class.new(filename, file_path, requesting_user_email) }
  let(:logger_double) { instance_double(ActiveSupport::Logger, warn: nil, error: nil) }

  before do
    allow(uploader).to receive(:logger).and_return(logger_double)
    allow(Rails).to receive(:logger).and_return(logger_double)
  end

  describe '#parse_file' do
    subject(:results) { uploader.parse_file }

    context 'when the file contains only valid numeric IDs' do
      let(:csv_content) do
        <<~CSV
          101
          102
          103
        CSV
      end

      it 'processes all rows' do
        expect(results.processed_count).to eq(3)
      end

      it 'identifies all IDs as valid' do
        expect(results.valid_affiliate_ids).to contain_exactly('101', '102', '103')
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

    context 'when the file contains non-numeric IDs' do
      let(:csv_content) do
        <<~CSV
          abc
          102
          def
        CSV
      end

      it 'processes all rows' do
        expect(results.processed_count).to eq(3)
      end

      it 'identifies only the valid ID' do
        expect(results.valid_affiliate_ids).to contain_exactly('102')
      end

      it 'reports failures for non-numeric IDs' do
        expect(results.failed_count).to eq(2)
        expect(results.error_details).to contain_exactly(
          { identifier: 'abc', error: 'Invalid format: Affiliate ID must be numeric.' },
                                           { identifier: 'def', error: 'Invalid format: Affiliate ID must be numeric.' }
        )
        expect(results.general_errors).to be_empty
      end

      it 'logs warnings for skipped non-numeric rows' do
        results

        expect(logger_double).to have_received(:warn).with(/Skipping row with non-numeric Affiliate ID 'abc'/).once
        expect(logger_double).to have_received(:warn).with(/Skipping row with non-numeric Affiliate ID 'def'/).once
      end

      it 'returns a partial completion summary message' do
        expect(results.summary_message).to eq("File parsing partially completed. 1 valid ID(s) found, 2 row(s) had errors. Deletion job proceeding. Check email for final results.")
      end
    end

    context 'when the file contains blank rows or rows with missing IDs' do
      let(:csv_content) do
        <<~CSV.chomp
          101

          103
          ""
          ,
        CSV
      end

      it 'identifies only the valid IDs' do
        expect(results.valid_affiliate_ids).to contain_exactly('101', '103')
      end

      it 'reports failures for rows without valid IDs or with non-numeric IDs' do
        expect(results.failed_count).to eq(3)
        expect(results.error_details).to contain_exactly(
          { identifier: 'N/A', error: 'Row contained no Affiliate ID.' },
                                           { identifier: 'N/A', error: 'Row contained no Affiliate ID.' },
                                           { identifier: 'N/A', error: 'Row contained no Affiliate ID.' }
        )
        expect(results.general_errors).to be_empty
      end

      it 'returns a partial completion summary message' do
        expect(results.summary_message).to eq("File parsing partially completed. 2 valid ID(s) found, 3 row(s) had errors. Deletion job proceeding. Check email for final results.")
      end
    end

    context 'when the file contains only invalid IDs (non-numeric)' do
      let(:csv_content) do
        <<~CSV
          abc
          def
        CSV
      end

      it 'processes all rows' do
        expect(results.processed_count).to eq(2)
      end

      it 'identifies no valid IDs' do
        expect(results.valid_affiliate_ids).to be_empty
      end

      it 'reports failures for all rows' do
        expect(results.failed_count).to eq(2)
        expect(results.error_details).to contain_exactly(
          { identifier: 'abc', error: 'Invalid format: Affiliate ID must be numeric.' },
                                           { identifier: 'def', error: 'Invalid format: Affiliate ID must be numeric.' }
        )
        expect(results.general_errors).to be_empty
      end

      it 'returns an error summary message indicating no valid IDs' do
        expect(results.summary_message).to eq("File parsing completed with errors. No valid IDs found, 2 row(s) failed.")
      end
    end

    context 'when the file is empty' do
      let(:csv_content) { "" }

      it 'processes zero rows' do
        expect(results.processed_count).to eq(0)
      end

      it 'identifies no valid IDs' do
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

    context 'when the file is malformed CSV' do
      let(:csv_content) { "101\n\"unterminated quote" }

      it 'catches the CSV::MalformedCSVError' do
        expect { results }.not_to raise_error(CSV::MalformedCSVError)
        expect(results.processed_count).to eq(1)
      end

      it 'identifies valid IDs processed before the error occurred' do
        expect(results.valid_affiliate_ids).to contain_exactly('101')
      end

      it 'reports no specific row failures (error is general)' do
        expect(results.failed_count).to eq(0)
        expect(results.error_details).to be_empty
      end

      it 'adds a general error for the malformed CSV' do
        expect(results.general_errors.first).to match("CSV file is malformed: Unclosed quoted field in line 2.")
      end

      it 'returns a general error summary message' do
        expect(results.summary_message).to match(/File parsing failed: CSV file is malformed: Unclosed quoted field in line 2\./)
      end
    end

    context 'when an unexpected error occurs during row processing' do
      let(:csv_content) { "101\n102" }
      let(:error_message) { 'Something broke!' }

      before do
        allow(uploader).to receive(:process_row).with(['101']).and_call_original
        allow(uploader).to receive(:process_row).with(['102']).and_raise(StandardError, error_message)
      end

      it 'processes all rows attempted before error' do
        expect(results.processed_count).to eq(2)
      end

      it 'captures valid IDs processed before the error' do
        expect(results.valid_affiliate_ids).to contain_exactly('101')
      end

      it 'reports a failure for the row that caused the error' do
        expect(results.failed_count).to eq(1)
        expect(results.error_details).to contain_exactly(
          { identifier: '102', error: "Error processing row: #{error_message}" }
        )
        expect(results.general_errors).to be_empty
      end

      it 'logs the row processing error' do
        results

        expect(logger_double).to have_received(:error).with(/Error processing bulk upload row.*Row: \["102"\].*Error: #{error_message}/)
      end

      it 'returns a partial completion summary message' do
        expect(results.summary_message).to eq("File parsing partially completed. 1 valid ID(s) found, 1 row(s) had errors. Deletion job proceeding. Check email for final results.")
      end
    end
  end
end
