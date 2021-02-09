# frozen_string_literal: true

When 'I download the top monthly queries report' do
  within('#report_links') do
    click_link('csv', match: :first)
  end
end
