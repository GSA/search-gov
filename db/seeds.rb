if Rails.env.development?
  require 'active_record/fixtures'
  ActiveRecord::Fixtures.create_fixtures(Rails.root.join('spec', 'fixtures'),
                                         %w(statuses))
  require_relative 'seeds/agency.rb'
  require_relative 'seeds/language.rb'
  require_relative 'seeds/affiliate.rb'
  require_relative 'seeds/email_template.rb'
  require_relative 'seeds/user.rb'
  require_relative 'seeds/search_module.rb'
elsif Rails.env.test?
  puts 'Skipping seeds in test environment; specs should create their own data'
else
  puts "Cowardly refusing to run seeds in #{Rails.env} environment"
end
