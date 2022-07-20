require 'spec_helper'

describe Sites::BoostedContentsBulkUploadsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }
  let(:site) { mock_model(Affiliate) }
  let(:success_message) do
    'Bulk upload is complete.<br/>You have added 3 Text Best Bets.<br/>You have updated 2 Text Best Bets.<br/>1 Text Best Bet was not uploaded. Please ensure the URLs are properly formatted, including the http:// or https:// prefix.'
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when the upload is successful' do
        before do
          uploader = double('BoostedContentBulkUploader')
          data_file = double('best bets text data file', to_s: 'file content')
          allow(BoostedContentBulkUploader).to receive(:new).and_return uploader
          expect(uploader).to receive(:upload).and_return({ created: 3, updated: 2, failed: 1 , success: true })

          post :create, params: { best_bets_text_data_file: data_file, site_id: site.id }
        end

        it { is_expected.to redirect_to(site_best_bets_texts_path(site)) }
        it { is_expected.to set_flash[:success].to(success_message) }
      end

      context 'when best bets text data file is not valid' do
        before do
          uploader = double('BoostedContentBulkUploader')
          data_file = double('best bets text data file', to_s: 'file content')
          allow(BoostedContentBulkUploader).to receive(:new).and_return uploader
          expect(uploader).to receive(:upload).and_return({ error_message: 'some error message' })

          post :create, params: { best_bets_text_data_file: data_file, site_id: site.id }
        end

        it { is_expected.to set_flash.now.to('some error message') }
        it { is_expected.to render_template(:new) }
      end
    end
  end
end
