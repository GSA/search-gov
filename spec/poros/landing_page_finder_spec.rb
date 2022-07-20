# frozen_string_literal: true

describe LandingPageFinder do
  describe '#landing_page' do
    include Rails.application.routes.url_helpers

    let(:user) { nil }
    let(:return_to) { nil }
    let(:finder) { described_class.new(user, return_to) }

    context 'with a user who is not approved' do
      let(:user) { users(:affiliate_manager_with_not_approved_status) }

      it 'raises an error' do
        expect { finder.landing_page }.
          to raise_error(LandingPageFinder::Error,
                         /Access Denied: These credentials are not recognized as valid/)
      end
    end

    context 'with a user who is pending approval' do
      let(:user) { users(:affiliate_manager_with_pending_approval_status) }

      it 'says they go to the "edit account" page' do
        expect(finder.landing_page).to eq(edit_account_path)
      end

      context 'when if there is a return_to page' do
        let(:return_to) { '/elsewhere' }

        it 'says they go to the edit account page ' do
          expect(finder.landing_page).to eq(edit_account_path)
        end
      end
    end

    context 'with a user who is incomplete' do
      let(:user) { users(:no_last_name) }

      it 'says they go to the "edit account" page' do
        expect(finder.landing_page).to eq(edit_account_path)
      end

      context 'when there is a return_to page' do
        let(:return_to) { '/oz' }

        it 'says they go to the edit account page ' do
          expect(finder.landing_page).to eq(edit_account_path)
        end
      end
    end

    context 'with a valid user and a return_to page' do
      let(:user) { users(:affiliate_manager) }
      let(:return_to) { '/barsoom' }

      it 'says they should go to the return_to page' do
        expect(finder.landing_page).to eq(return_to)
      end
    end

    context 'with a user who is an affiliate admin' do
      let(:user) { users(:affiliate_admin) }

      it 'says they go to the "admin home" page' do
        expect(finder.landing_page).to eq(admin_home_page_path)
      end

      context 'when is a return_to page' do
        let(:return_to) { '/nyc' }

        it 'says they go to the return_to page ' do
          expect(finder.landing_page).to eq(return_to)
        end
      end
    end

    context 'with a user who has a default site set' do
      let(:user) { users(:affiliate_manager_with_a_default_site) }

      it 'says they go to the page for the site' do
        expect(finder.landing_page).to eq(site_path(user.default_affiliate))
      end

      context 'when there is a return_to page' do
        let(:return_to) { '/pittsburgh' }

        it 'says they go to the return_to page ' do
          expect(finder.landing_page).to eq(return_to)
        end
      end
    end

    context 'with a user who has no default site, but is an affiliate' do
      let(:user) { users(:affiliate_manager_with_one_site) }

      context 'when there is a return_to page' do
        let(:return_to) { '/reno' }

        it 'says they go to the return_to page ' do
          expect(finder.landing_page).to eq(return_to)
        end
      end

      it 'says they go to the page for the first site they are affiliated with' do
        expect(finder.landing_page).to eq(site_path(user.affiliates.first))
      end
    end

    context 'with a user who is not affiliated with any sites' do
      let(:user) { users(:affiliate_manager_with_no_affiliates) }

      it 'says they go to the new site page' do
        expect(finder.landing_page).to eq(new_site_path)
      end

      context 'when there is a return_to page' do
        let(:return_to) { '/rockville' }

        it 'says they go to the return_to page ' do
          expect(finder.landing_page).to eq(return_to)
        end
      end
    end
  end
end
