# frozen_string_literal: true

require 'spec_helper'

describe 'scheduled jobs configuration' do
  let(:resque_schedule) do
    YAML.safe_load(Rails.root.join('config/resque_schedule.yml').read)
  end

  let(:whenever_source) do
    Rails.root.join('config/schedule.rb').read.
      lines.reject { |line| line.match?(/^\s*#/) }.join
  end

  let(:yaml_job_classes) { resque_schedule.fetch('production').keys }

  let(:whenever_job_classes) do
    whenever_source.scan(/\b([A-Z][A-Za-z0-9]*Job)\b/).flatten.uniq
  end

  it 'schedules SitemapMonitorJob via resque-scheduler in production' do
    expect(resque_schedule.fetch('production').fetch('SitemapMonitorJob')).
      to eq('cron' => '0 */4 * * *')
  end

  it 'does not list the same job class in resque_schedule.yml and schedule.rb' do
    expect(yaml_job_classes & whenever_job_classes).to eq([])
  end

  it 'limits whenever entries to rake, runner, or command' do
    job_methods = whenever_source.scan(/^\s+(rake|runner|command|job|script)\b/).flatten.uniq
    expect(job_methods - %w[rake runner command]).to eq([])
  end
end
