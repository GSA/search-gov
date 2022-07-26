should_seed_staging = !ENV["SHOULD_SEED_STAGING_DB"].nil? && Language.count == 0

if Rails.env.development? || should_seed_staging
  require_relative 'seeds/agency.rb'
  require_relative 'seeds/language.rb'
  require_relative 'seeds/affiliate.rb'
  require_relative 'seeds/email_template.rb'
  require_relative 'seeds/search_module.rb'
elsif Rails.env.test?
  puts 'Skipping seeds in test environment; specs should create their own data'
else
  puts "Cowardly refusing to run seeds in #{Rails.env} environment"
end
