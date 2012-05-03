namespace :usasearch do
  namespace :features do

    desc "Record feature usage/addition for an affiliate. Takes feature internal_name and a file containing a list of affiliate IDs"
    task :record_feature_usage, :feature_internal_name, :file_name, :needs => :environment do |t, args|
      if args.file_name.nil? or args.feature_internal_name.nil?
        Rails.logger.error "usage: rake usasearch:features:record_feature_usage[feature_internal_name, file_name]"
      else
        feature = Feature.find_by_internal_name(args.feature_internal_name)
        File.open(args.file_name).each do |line|
          affiliate = Affiliate.find line.chomp
          affiliate.features << feature unless affiliate.features.include?(feature)
        end
      end
    end

    desc "Email admin about new feature usage from yesterday"
    task :email_admin_about_new_feature_usage => :environment do
      Emailer.new_feature_adoption_to_admin.deliver rescue nil
    end

    desc "Email newish users about features they haven't yet implemented"
    task :user_feature_reminder, :created_days_back, :needs => :environment do |t, args|
      args.with_defaults(:created_days_back => 3)
      target_day = args.created_days_back.to_i.days.ago
      User.where(["created_at between ? and ?", target_day.beginning_of_day, target_day.end_of_day]).each do |user|
        affiliates_with_unused_features = user.affiliates.select { |affiliate| affiliate.unused_features.any? }
        Emailer.feature_admonishment(user, affiliates_with_unused_features).deliver if affiliates_with_unused_features.any?
      end
    end
  end
end