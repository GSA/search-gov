require 'spec_helper'

describe Sites::BoostedContentsBulkUploadsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }
  let(:site) { mock_model(Affiliate) }
  let(:success_message) do
    "Bulk upload is complete.<br/>You have added 3 Text Best Bets.<br/>You have updated 2 Text Best Bets.<br/>1 Text Best Bet was not uploaded. Please ensure the URLs are properly formatted, including the http:// or https:// prefix."
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when the upload is successful' do
        before do
          uploader = double('BoostedContentBulkUploader')
          data_file = double('best bets text data file', to_s: 'file content')
          BoostedContentBulkUploader.stub(:new).and_return uploader
          uploader.should_receive(:upload).and_return({ created: 3, updated: 2, failed: 1 , success: true })

          post :create, best_bets_text_data_file: data_file
        end

        it { should redirect_to(site_best_bets_texts_path(site)) }
        it { should set_flash.to(success_message).now }
      end

      context 'when best bets text data file is not valid' do
        before do
          uploader = double('BoostedContentBulkUploader')
          data_file = double('best bets text data file', to_s: 'file content')
          BoostedContentBulkUploader.stub(:new).and_return uploader
          uploader.should_receive(:upload).and_return({ error_message: 'some error message' })

          post :create, best_bets_text_data_file: data_file
        end

        it { should set_flash.to('some error message').now }
        it { should render_template(:new) }
      end
    end
  end
end
