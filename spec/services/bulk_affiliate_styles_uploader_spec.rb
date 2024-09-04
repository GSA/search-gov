describe BulkAffiliateStylesUploader do
  let(:filename) { 'affiliate_styles.csv' }
  let(:filepath) { Rails.root.join('spec/fixtures/csv/affiliate_styles.csv') }
  let(:uploader) { described_class.new(filename, filepath) }
  let(:affiliate) { instance_double(Affiliate, id: 1, primary_header_links: [], secondary_header_links: [], footer_links: [], identifier_links: [], visual_design_json: {}, display_logo_only: false, identifier_domain_name: '', parent_agency_name: '', parent_agency_link: '').as_null_object }

  describe '#upload' do
    context 'when processing a valid file' do
      before do
        allow(File).to receive(:read).and_return(File.read(filepath))
        allow(CSV).to receive(:parse).and_return([{ 'ID' => '1', 'banner_background_color' => '#ffffff' }])
        allow(Affiliate).to receive_messages(find: affiliate, save!: true)
      end

      it 'returns a Results object with the correct attributes' do
        results = uploader.upload

        expect(results).to be_a(BulkAffiliateStyles::Results)
        expect(results.file_name).to eq(filename)
        expect(results.ok_count).to eq(1)
        expect(results.error_count).to eq(0)
        expect(results.affiliates).to include('1')
      end
    end

    context 'when processing an invalid file' do
      before do
        allow(File).to receive(:read).and_return(File.read(filepath))
        allow(CSV).to receive(:parse).and_raise(StandardError.new('Invalid CSV format'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs an error and returns a Results object with errors' do
        results = uploader.upload

        expect(Rails.logger).to have_received(:error).with(/Problem processing affiliate styles document/)
        expect(results).to be_a(BulkAffiliateStyles::Results)
        expect(results.file_name).to eq(filename)
        expect(results.ok_count).to eq(0)
        expect(results.error_count).to eq(0)
        expect(results.affiliates).to be_empty
        expect(results.instance_variable_get(:@errors)).to be_empty
      end
    end

    context 'when an error occurs during row processing' do
      before do
        allow(File).to receive(:read).and_return(File.read(filepath))
        allow(CSV).to receive(:parse).and_return([{ 'ID' => '1', 'banner_background_color' => '#ffffff' }])
        allow(Affiliate).to receive(:find).and_raise(StandardError.new('Test error'))
        allow(Rails.logger).to receive(:error)
      end

      it 'adds an error and logs it' do
        results = uploader.upload

        expect(results.error_count).to eq(1)
        expect(results.instance_variable_get(:@errors)['1']).to eq('Test error')
        expect(Rails.logger).to have_received(:error).with(/Failure to process bulk upload affiliate styles row:/)
      end
    end
  end
end
