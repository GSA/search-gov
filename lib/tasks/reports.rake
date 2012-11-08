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
      User.where(:is_affiliate => true).where(:approval_status => 'approved').each do |user|
        Emailer.affiliate_monthly_report(user, report_date).deliver if user.affiliates.present?
      end
    end
  end
end