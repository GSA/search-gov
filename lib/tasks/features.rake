namespace :usasearch do
  namespace :features do

    desc "Record feature usage/addition for an affiliate. Takes feature internal_name and a file containing a list of affiliate IDs"
    task :record_feature_usage, [:feature_internal_name, :file_name] => [:environment] do |t, args|
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
      Emailer.new_feature_adoption_to_admin.deliver_now rescue nil
    end

  end
end
