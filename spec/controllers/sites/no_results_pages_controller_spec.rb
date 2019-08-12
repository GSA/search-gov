require 'spec_helper'

describe Sites::NoResultsPagesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when site alternative links are not valid' do
        before do
          expect(site).to receive(:update_attributes).
              with(hash_including("additional_guidance_text"=>"Testadfaf",
              'managed_no_results_pages_alt_links_attributes' => {
                "0"=>
                  {"title"=>"test",
                    "position"=>"0",
                    "url"=>"http://google.com"
                    }
                }
              )).
              and_return(false)

          put :update,
              params: {
                site_id: site.id,
                id: 100,
                no_results_pages: {'additional_guidance_text': 'Testadfaf',
                                   'managed_no_results_pages_alt_links_attributes': {
                                     '0': {
                                       'title': 'test',
                                       'position': '0',
                                       'url': 'http://google.com'
                                     }
                                   }
                }
              }
        end

        it { is_expected.to render_template(:edit) }
      end
    end
  end
end
