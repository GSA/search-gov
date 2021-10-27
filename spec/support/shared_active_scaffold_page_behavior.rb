# frozen_string_literal: true

# Very basic smoke test of ActiveScaffold components; click on each of
# the actions and make sure it doesn't explode.
shared_examples 'an ActiveScaffold page' do |actions, page_text|
  describe 'the actions' do
    before { visit(url) }

    include_context 'log in super admin'

    actions.each do |action|
      describe action do
        before do
          first('td.actions').click_link action
          page.driver.browser.switch_to.alert.accept if action == 'Delete'
        end

        it 'leaves us on the page' do
          expect(page).to have_text(page_text)
        end
      end
    end
  end
end

shared_examples 'a Create New' do
  context 'when a super admin is logged in', :js do
    include_context 'log in super admin'

    before do
      visit(url)
      click_link 'Create New'
      sleep(0.5)
    end

    it 'pops up the create panel' do
      expect(find('form.create')).not_to be_nil
    end
  end
end

shared_examples 'a Search' do
  context 'when a super admin is logged in', :js do
    include_context 'log in super admin'
    before do
      visit(url)
      click_link 'Search'
      sleep(0.5)
    end

    it 'pops up the search panel' do
      expect(find('form.search')).not_to be_nil
    end
  end
end
