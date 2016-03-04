require 'spec_helper'

describe Sites::BoostedContentsBulkUploadsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when best bets text data file is not valid' do
        before do
          uploader = mock('BoostedContentBulkUploader')
          data_file = mock('best bets text data file', to_s: 'file content')
          BoostedContentBulkUploader.stub(:new).and_return uploader
          uploader.should_receive(:upload).and_return({ error_message: 'some error message' })

          post :create, best_bets_text_data_file: data_file
        end

        it { should set_the_flash.to('some error message').now }
        it { should render_template(:new) }
      end
    end
  end

end
