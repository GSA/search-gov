require 'spec_helper'

describe 'searchgov:set_header_background_color', type: :task do
  let(:task_name) { 'searchgov:set_header_background_color' }
  let(:task) { Rake::Task[task_name] }
  let(:csv_file_path) { Rails.root.join('spec/fixtures/csv/header_bg_color.csv') }
  let(:affiliate) { affiliates(:usagov_affiliate_header_bg_color) }

  before do
    Rake.application.rake_require('tasks/header_bg_color_updater')
    Rake::Task.define_task(:environment)
    task.reenable
  end

  it 'corrects the header_background_color for the affiliates in the CSV file' do
    task.invoke(csv_file_path.to_s)

    affiliate.reload

    expect(affiliate.visual_design_json['header_background_color']).to eq('#FFFFFF')
  end
end
