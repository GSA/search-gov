namespace :usasearch do
  namespace :reports do

    desc "Email approved affiliate users with active site(s) monthly affiliate report"
    task :email_monthly_reports, [:report_year_month] => [:environment] do |t, args|
      report_date = args.report_year_month.blank? ? Date.yesterday : Date.parse(args.report_year_month + "-01")
      User.approved_affiliate.each do |user|
        begin
          Emailer.affiliate_monthly_report(user, report_date).deliver if user.affiliates.present?
        rescue Exception => e
          Rails.logger.warn "Trouble emailing monthly report to user #{user.id}: #{e}"
        end
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
  end
end
