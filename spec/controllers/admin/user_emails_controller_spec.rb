require 'spec_helper'

describe Admin::UserEmailsController do
  render_views
  fixtures :users

  before { allow(MandrillAdapter).to receive(:new).and_return(adapter) }
  let(:adapter) { double(MandrillAdapter) }
  let(:target_user) { users('affiliate_manager') }

  context 'when not logged in' do
    describe '#index' do
      it 'should redirect to the login page' do
        get :index, id: target_user.id
        expect(response).to redirect_to(login_path)
      end
    end

    describe '#merge_tags' do
      it 'should redirect to the login page' do
        get :merge_tags, id: target_user.id, email_id: 'Template A'
        expect(response).to redirect_to(login_path)
      end
    end

    describe '#send_to_admin' do
      it 'should redirect to the login page' do
        post :send_to_admin, id: target_user.id, email_id: 'Template A'
        expect(response).to redirect_to(login_path)
      end
    end

    describe '#send_to_user' do
      it 'should redirect to the login page' do
        post :send_to_user, id: target_user.id, email_id: 'Template A'
        expect(response).to redirect_to(login_path)
      end
    end
  end

  context 'when logged in as a non-affiliate-admin user' do
    before do
      activate_authlogic
      UserSession.create(users("non_affiliate_admin"))
    end

    describe '#index' do
      it 'should redirect to the account page' do
        get :index, id: target_user.id
        expect(response).to redirect_to(account_path)
      end
    end

    describe '#merge_tags' do
      it 'should redirect to the account page' do
        get :merge_tags, id: target_user.id, email_id: 'Template A'
        expect(response).to redirect_to(account_path)
      end
    end

    describe '#send_to_admin' do
      it 'should redirect to the account page' do
        post :send_to_admin, id: target_user.id, email_id: 'Template A'
        expect(response).to redirect_to(account_path)
      end
    end

    describe '#send_to_user' do
      it 'should redirect to the account page' do
        post :send_to_user, id: target_user.id, email_id: 'Template A'
        expect(response).to redirect_to(account_path)
      end
    end
  end

  context 'when logged in as an affiliate-admin user' do
    before do
      activate_authlogic
      UserSession.create(users("affiliate_admin"))
    end

    describe '#index' do
      context 'when no client is present' do
        before { allow(adapter).to receive(:template_names).and_raise(MandrillAdapter::NoClient) }

        it 'should show a no-client error' do
          get :index, id: target_user.id
          expect(response.body).to match(/No Mandrill client/)
        end
      end

      context 'when a client is present' do
        before { allow(adapter).to receive(:template_names).and_return(['Template A', 'Template B']) }

        it 'should show a list of template names' do
          get :index, id: target_user.id
          expect(response.body).to match(/Template A/)
          expect(response.body).to match(/Template B/)
        end
      end
    end

    describe '#merge_tags' do
      context 'when no client is present' do
        before { allow(adapter).to receive(:preview_info).and_raise(MandrillAdapter::NoClient) }

        it 'should show a no-client error' do
          get :merge_tags, id: target_user.id, email_id: 'Template A'
          expect(response.body).to match(/No Mandrill client/)
        end
      end

      context 'when the referenced template does not exist' do
        before do
          allow(adapter).to receive(:preview_info).with(target_user, 'Template A').and_raise(MandrillAdapter::UnknownTemplate)
        end

        it 'should show an error message' do
          get :merge_tags, id: target_user.id, email_id: 'Template A'
          expect(flash[:error]).to eq("Unknown template 'Template A'.")
        end
      end

      context 'when a client is present' do
        before do
          allow(adapter).to receive(:preview_info).with(target_user, 'Template A').and_return({
            to: 'Joe Something <joe@example.com>',
            subject: 'Welcome, dear user',
            to_admin: to_admin,
            merge_tags: {
              available: {
                organization_name: 'The Organization',
              },
              needed: [
                :first_name,
              ],
            },
          })

          get :merge_tags, id: target_user.id, email_id: 'Template A'
        end

        let(:to_admin) { true }

        it 'should show the recipient info' do
          body = HTMLEntities.new.decode response.body
          expect(body).to match(%r{Template:.*?Template A}m)
          expect(body).to match(%r{Send to:.*?Joe Something <joe@example.com>}m)
          expect(body).to match(%r{Subject:.*?Welcome, dear user}m)
        end

        it 'should show default merge field values' do
          expect(response.body).to have_selector('input#organization_name[value="The Organization"]')
        end

        it 'should have input fields for needed merge field values' do
          expect(response.body).to have_selector('input', id: 'first_name')
        end

        context 'when the template is meant to be sent to admins not users' do
          let(:to_admin) { true }

          it 'should have a send-to-admin form' do
            action = URI.unescape(admin_email_send_to_admin_path(id: target_user.id, email_id: 'Template A'))
            expect(response.body).to have_selector(:css, "form[action='#{action}'][method=post]")
          end
        end

        context 'when the template is meant to be sent to users not admins' do
          let(:to_admin) { false }

          it 'should have a send-to-user form' do
            action = URI.unescape(admin_email_send_to_user_path(id: target_user.id, email_id: 'Template A'))
            expect(response.body).to have_selector(:css, "form[action='#{action}'][method=post]")
          end
        end
      end
    end

    describe '#send_to_admin' do
      it 'sends an email to the admin' do
        expect(adapter).to receive(:send_admin_email).with(target_user, 'Template A', {
          'first' => 'Joe',
          'last' => 'Something',
        })

        post :send_to_admin, {
          id: target_user.id,
          email_id: 'Template A',
          first: 'Joe',
          last: 'Something',
        }
      end
    end

    describe '#send_to_user' do
      it 'sends and email to the target user' do
        expect(adapter).to receive(:send_user_email).with(target_user, 'Template A', {
          'first' => 'Joe',
          'last' => 'Something',
        })

        post :send_to_user, {
          id: target_user.id,
          email_id: 'Template A',
          first: 'Joe',
          last: 'Something',
        }
      end
    end
  end
end
