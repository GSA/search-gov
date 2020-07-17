shared_examples "a landing page" do
  context 'when the user is pending approval' do
    let(:user_approval_status) { 'pending_approval' }

    it 'is the users account page' do
      expect(page).to have_current_path(edit_account_path, ignore_query: true)
    end

    context 'when they specified an explicit destination' do
      let(:explicit_destination) { '/sites/new' }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end
  end

  context 'when the user is not complete because missing a first name' do
    let(:user_first_name) { nil }

    it 'is the users account page' do
      expect(page).to have_current_path(edit_account_path, ignore_query: true)
    end

    context 'when they specified an explicit destination' do
      let(:explicit_destination) { '/sites/new' }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end
  end

  context 'when the user is not complete because missing a last name' do
    let(:user_last_name) { nil }

    it 'is the users account page' do
      expect(page).to have_current_path(edit_account_path, ignore_query: true)
    end

    context 'when they specified an explicit destination' do
      let(:explicit_destination) { '/sites/new' }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end
  end

  context 'when the user is not complete because missing an organization name' do
    let(:user_organization_name) { nil }

    it 'is the users account page' do
      expect(page).to have_current_path(edit_account_path, ignore_query: true)
    end

    context 'when they specified an explicit destination' do
      let(:explicit_destination) { '/sites/new' }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end
  end

  context 'when the user is not associated with any affiliates' do
    let(:user_affiliates) { [] }

    it 'is the new site page' do
      expect(page).to have_current_path(new_site_path, ignore_query: true)
    end

    context 'when they specified an explicit destination' do
      let(:explicit_destination) { '/sites/new' }

      it 'is the specified destination' do
        expect(page).to have_current_path(explicit_destination)
      end
    end
  end

  context 'when the user is a member of at least one affiliate' do
    let(:user_affiliates) { [first_affiliate, second_affiliate] }

    it 'is the first affiliate the user is a member of' do
      expect(page).to have_current_path(site_path(first_affiliate), ignore_query: true)
    end

    context 'when they specified an explicit destination' do
      let(:explicit_destination) { '/sites/new' }

      it 'is the specified destination' do
        expect(page).to have_current_path(explicit_destination)
      end
    end
  end

  context 'when the user has a default affiliate' do
    let(:user_affiliates) { [first_affiliate, second_affiliate] }
    let(:user_default_affiliate) { second_affiliate }

    it 'is the default affiliate' do
      expect(page).to have_current_path(
        site_path(user_default_affiliate),
        ignore_query: true
      )
    end

    context 'when they specified an explicit destination' do
      let(:explicit_destination) { '/sites/new' }

      it 'is the specified destination' do
        expect(page).to have_current_path(explicit_destination)
      end
    end
  end

  context 'when the user is a super admin' do
    let(:user_is_super_admin) { true }

    it 'is the admin page' do
      expect(page).to have_current_path(admin_home_page_path, ignore_query: true)
    end

    context 'when they specified an explicit destination' do
      let(:explicit_destination) { '/sites/new' }

      it 'is the specified destination' do
        expect(page).to have_current_path(explicit_destination)
      end
    end
  end
end
