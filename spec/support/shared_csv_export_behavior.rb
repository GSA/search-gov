# frozen_string_literal: true

shared_examples 'a CSV export' do
  context 'when a super admin is logged in', :js do
    include_context 'log in super admin'
    before do
      visit(url)
      click_link 'Export'
      sleep(0.1)
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
