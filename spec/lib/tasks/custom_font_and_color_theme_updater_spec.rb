# frozen_string_literal: true

require 'rake'

describe 'searchgov:custom_font_and_color_theme_updater' do
  let(:custom_font_and_color_theme_updater) { instance_double(CustomFontAndColorThemeUpdater) }
  let(:run_task) do
    Rake.application.invoke_task "searchgov:custom_font_and_color_theme_updater[#{ids}]"
  end

  before do
    Rake.application.rake_require('tasks/custom_font_and_color_theme_updater')
    Rake::Task.define_task(:environment)
    allow(CustomFontAndColorThemeUpdater).to receive(:new).and_return(custom_font_and_color_theme_updater)
    allow(custom_font_and_color_theme_updater).to receive(:update)
  end

  context 'when select ids are passed as an argument' do
    before do
      Rake::Task['searchgov:custom_font_and_color_theme_updater'].reenable
    end

    let(:first_affiliate_id) { affiliates(:redesigned_usagov_affiliate).id }
    let(:second_affiliate_id) { affiliates(:i14y_affiliate).id }
    let(:ids) { "#{first_affiliate_id} #{second_affiliate_id}" }

    it 'calls the updater on those ids' do
      run_task

      expect(CustomFontAndColorThemeUpdater).to have_received(:new)
      expect(custom_font_and_color_theme_updater).to have_received(:update).with("#{first_affiliate_id} #{second_affiliate_id}")
    end
  end

  context 'when all ids are passed as an argument' do
    before do
      Rake::Task['searchgov:custom_font_and_color_theme_updater'].reenable
    end

    let(:ids) { 'all' }

    it 'calls the updater on those ids' do
      run_task

      expect(CustomFontAndColorThemeUpdater).to have_received(:new)
      expect(custom_font_and_color_theme_updater).to have_received(:update).with('all')
    end
  end

  context 'when id argument is absent' do
    before do
      Rake::Task['searchgov:custom_font_and_color_theme_updater'].reenable
    end

    let(:run_task) { Rake.application.invoke_task 'searchgov:custom_font_and_color_theme_updater' }
    let(:warn_text) { "Please provide a space-separated list of affiliate ids or 'all' as a task argument. No affiliates updated.\n" }

    it 'raises a warning and exits' do
      expect { run_task }.to output(warn_text).to_stdout
    end
  end
end
