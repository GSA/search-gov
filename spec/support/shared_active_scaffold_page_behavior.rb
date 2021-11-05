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
          click_link(action, match: :first)
          page.driver.browser.switch_to.alert.accept if action == 'Delete'
        end

        it 'leaves us on the page' do
          expect(page).to have_text(page_text)
        end
      end
    end
  end
end

shared_examples 'a page that can export data' do
  context 'when a super admin is logged in', :js do
    include_context 'log in super admin'

    before do
      visit(url)
      click_link 'Export'
      wait_for_ajax
      click_button 'Export'
    end

    after { FileUtils.rm_f(downloaded_csv) }

    it 'creates the CSV file' do
      Timeout.timeout(5) do
        loop do
          break if File.exist?(downloaded_csv)
        end
      end

      expect(File).to exist(downloaded_csv)
    end
  end
end
