require 'spec_helper'

module ApplicationHelper
  def current_user
    User.new
  end
end

describe 'sites/shared/_site_header' do

  context 'inactive affiliate banner' do
    context 'when site is active' do
      before { assign(:site, double('Site', active?: true, new_record?: true)) }

      it 'does not render the inactive banner' do
        render
        expect(rendered).not_to have_selector('.site-header-inactive[aria-label="Inactive affiliate notification"]')
      end
    end

    context 'when site is inactive' do
      before { assign(:site, double('Site', active?: false, new_record?: true)) }

      it 'renders the inactive banner' do
        render
        expect(rendered).to have_selector('.site-header-inactive[aria-label="Inactive affiliate notification"]')
      end
    end

    context 'when site is nil (user-scoped pages)' do
      before { assign(:site, nil) }

      it 'does not render the inactive banner' do
        render
        expect(rendered).not_to have_selector('.site-header-inactive[aria-label="Inactive affiliate notification"]')
      end
    end
  end
end
