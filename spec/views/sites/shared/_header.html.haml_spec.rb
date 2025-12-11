require 'spec_helper'

module ApplicationHelper
  def current_user
    User.new
  end
end

describe 'sites/shared/_header' do
  before do
    @site = double('Site', active?: true)
  end

  it_behaves_like 'a non-prod git info banner'

  context 'inactive affiliate banner' do
    context 'when site is active' do
      before { @site = double('Site', active?: true) }

      it 'does not render the inactive banner' do
        render
        expect(rendered).not_to have_selector('section[aria-label="Inactive affiliate notification"]')
      end
    end

    context 'when site is inactive' do
      before { @site = double('Site', active?: false) }

      it 'renders the inactive banner' do
        render
        expect(rendered).to have_selector('section[aria-label="Inactive affiliate notification"]')
      end
    end

    context 'when site is nil (user-scoped pages)' do
      before { @site = nil }

      it 'does not render the inactive banner' do
        render
        expect(rendered).not_to have_selector('section[aria-label="Inactive affiliate notification"]')
      end
    end
  end
end
