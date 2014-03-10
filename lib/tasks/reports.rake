namespace :usasearch do
  namespace :reports do

    desc "Generate Top Queries reports (daily, weekly, or monthly) per affiliate on S3 from CTRL-A delimited input file containing affiliate name, query, raw count"
    task :generate_top_queries_from_file, [:file_name, :period, :max_entries_per_group, :date] => [:environment] do |t, args|
      if args.file_name.nil? or args.period.nil? or args.max_entries_per_group.nil?
        Rails.logger.error "usage: rake usasearch:reports:generate_top_queries_from_file[file_name,monthly|weekly|daily,1000]"
      else
        day = args.date.nil? ? Date.yesterday : Date.parse(args.date)
        report = Report.new(args.file_name, args.period, args.max_entries_per_group.to_i, day)
        report.generate_top_queries_from_file
      end
    end

    desc "Email approved affiliate users with active site(s) monthly affiliate report"
    task :email_monthly_reports, [:report_year_month] => [:environment] do |t, args|
      report_date = args.report_year_month.blank? ? Date.yesterday : Date.parse(args.report_year_month + "-01")
      User.approved_affiliate.each do |user|
        Emailer.affiliate_monthly_report(user, report_date).deliver if user.affiliates.present?
      end
    end

    desc "Email approved affiliate users with active site(s) yearly affiliate report"
    task :email_yearly_reports, [:report_year] => [:environment] do |t, args|
      report_year = args.report_year || Date.current.year
      User.approved_affiliate.each do |user|
        begin
          Emailer.affiliate_yearly_report(user, report_year.to_i).deliver if user.affiliates.present?
        rescue Exception => e
          Rails.logger.warn "Trouble emailing yearly report to user #{user.id}: #{e}"
        end
      end
    end

    desc "Email opted-in site users with site snapshot"
    task :daily_snapshot => :environment do
      Membership.daily_snapshot_receivers.each do |membership|
        Emailer.daily_snapshot(membership).deliver
      end
    end
  end
end