# frozen_string_literal: true

require 'spec_helper'

describe 'scheduled jobs configuration' do
  let(:resque_schedule) do
    YAML.safe_load(Rails.root.join('config/resque_schedule.yml').read)
  end

  it 'schedules SitemapMonitorJob only via resque-scheduler in production' do
    production = resque_schedule.fetch('production')
    expect(production.keys).to eq(['SitemapMonitorJob'])
    expect(production.fetch('SitemapMonitorJob')).to eq('cron' => '0 */4 * * *')
  end

  it 'does not schedule SitemapMonitorJob via whenever' do
    schedule = Rails.root.join('config/schedule.rb').read
    expect(schedule).not_to match(/runner ['"]SitemapMonitorJob/)
    expect(schedule).not_to match(/rake ['"][^'"]*SitemapMonitor/)
  end
end
