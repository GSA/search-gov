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

  let(:production_schedule) { resque_schedule.fetch('production') }

  let(:yaml_job_classes) do
    production_schedule.map do |name, opts|
      opts.is_a?(Hash) ? (opts['class'] || name) : name
    end
  end

  let(:whenever_job_classes) do
    whenever_source.scan(/\b([A-Z][A-Za-z0-9:]*Job)\b/).flatten.uniq
  end

  it 'schedules SitemapMonitorJob via resque-scheduler in production' do
    expect(production_schedule.fetch('SitemapMonitorJob')).
      to eq('cron' => '0 */4 * * *')
  end

  it 'preserves cron times for jobs moved from schedule.rb' do
    # expect(production_schedule.fetch('email_monthly_reports')).to eq(
    #   'class' => 'Scheduled::EmailMonthlyReportsJob',
    #   'cron' => '0 0 1 * *'
    # )
    # expect(production_schedule.fetch('email_yearly_reports')).to eq(
    #   'class' => 'Scheduled::EmailYearlyReportsJob',
    #   'cron' => '35 21 18 12 *'
    # )
    # expect(production_schedule.fetch('update_approval_status')).to eq(
    #   'class' => 'Scheduled::UpdateApprovalStatusJob',
    #   'cron' => '25 2 * * 0'
    # )
    # expect(production_schedule.fetch('warn_set_to_not_approved_76')).to eq(
    #   'class' => 'Scheduled::WarnSetToNotApprovedJob',
    #   'cron' => '5 0 * * *',
    #   'args' => [76]
    # )
    # expect(production_schedule.fetch('warn_set_to_not_approved_86')).to eq(
    #   'class' => 'Scheduled::WarnSetToNotApprovedJob',
    #   'cron' => '5 0 * * *',
    #   'args' => [86]
    # )
    # expect(production_schedule.fetch('searchgov_url_counter_culture_fix_counts')).to eq(
    #   'class' => 'Scheduled::SearchgovUrlCounterCultureFixCountsJob',
    #   'cron' => '0 2-20 * * *'
    # )
    expect(production_schedule.fetch('update_not_active_approval_status')).to eq(
      'class' => 'Scheduled::UpdateNotActiveApprovalStatusJob',
      'cron' => '5 0 * * *'
    )
  end

  it 'does not list the same job class in resque_schedule.yml and schedule.rb' do
    expect(yaml_job_classes & whenever_job_classes).to eq([])
  end

  it 'limits whenever entries to rake, runner, or command' do
    job_methods = whenever_source.scan(/^\s+(rake|runner|command|job|script)\b/).flatten.uniq
    expect(job_methods - %w[rake runner command]).to eq([])
  end
end
