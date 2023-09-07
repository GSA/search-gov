# frozen_string_literal: true

describe Sites::VisualDesignsController do
  before { activate_authlogic }

  describe '#edit' do
    it_behaves_like 'restricted to approved user', :get, :edit, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before { get :edit, params: { site_id: site.id } }

      it { is_expected.to assign_to(:site).with(site) }
    end
  end

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when site params are valid' do
        let(:valid_params) do
          {
            site_id: site.id,
            site: {
              visual_design_json: {
                header_links_font_family: "'Georgia', 'Cambria', 'Times New Roman', 'Times', serif",
                footer_and_results_font_family: "'Helvetica Neue', 'Helvetica', 'Roboto', 'Arial', sans-serif"
              }
            }
          }
        end

        before { put :update, params: valid_params }

        it { is_expected.to redirect_to(edit_site_visual_design_path(site)) }

        it 'sets the flash success message' do
          expect(flash[:success]).to match('You have updated your visual design settings.')
        end

        context 'when attaching a logo' do
          let(:attachment_params) do
            {
              site_id: site.id,
              site: {
                header_logo: logo_file
              }
            }
          end
          let(:logo_file) { fixture_file_upload(Rails.root.join('spec/fixtures/images/dog.jpg'), 'image/jpeg') }

          it 'adds an ActiveStorage attachment' do
            expect { put :update, params: attachment_params }.
              to change { ActiveStorage::Attachment.count }.from(0).to(1)
          end

          context 'when a header logo is attached' do
            before { put :update, params: attachment_params }

            context 'when the header logo alt text is updated' do
              let(:alt_text_params) do
                {
                  site_id: site.id,
                  site: {
                    header_logo_blob_attributes: {
                      checksum: site.header_logo.checksum,
                      id: site.header_logo.blob_id,
                      custom_metadata: {
                        alt_text: 'Some new alt text'
                      }
                    }
                  }
                }
              end

              before { put :update, params: alt_text_params }

              it 'updates the custom metadata' do
                expect(site.header_logo.custom_metadata).to eq({ 'alt_text' => 'Some new alt text' })
              end
            end

            context 'when that attachment is marked for deletion' do
              let(:deletion_params) do
                {
                  site_id: site.id,
                  site: {
                    header_logo_attachment_attributes: {
                      id: site.header_logo.id,
                      _destroy: 1
                    }
                  }
                }
              end

              it 'enqueues a purge job on the searchgov queue' do
                expect { put :update, params: deletion_params }.
                  to have_enqueued_job(ActiveStorage::PurgeJob).
                  on_queue('searchgov').
                  with(site.header_logo.blob)
              end
            end
          end
        end
      end

      context 'when site params are not valid' do
        let(:invalid_params) do
          {
            site_id: site.id,
            site: {
              visual_design_json: {
                header_links_font_family: 'comic sans',
                footer_and_results_font_family: 'invalid'
              }
            }
          }
        end

        before { put :update, params: invalid_params }

        it { is_expected.to render_template(:edit) }
      end
    end
  end

  describe '#new_link' do
    it_behaves_like 'restricted to approved user', :get, :new_link, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        get :new_link, params: {
          site_id: site.id,
          index: 0,
          type: 'secondary_header'
        }, xhr: true, format: :js
      end

      it { is_expected.to render_template(:new_link) }
    end
  end
end
