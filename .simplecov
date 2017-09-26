if ENV['CIRCLECI'] || ENV['TRAVIS'] # output text for CI
  SimpleCov.at_exit do
    result_hash = SimpleCov.result.to_hash

    if result_hash.keys == ['Cucumber, RSpec'] #make sure we're done
      if SimpleCov.result.covered_percent < 100
        puts "=========== Lines missing coverage: ==========="
        result_hash['Cucumber, RSpec']['coverage'].each do |file_name, file_lines|
           file_lines.each_with_index { |val, index| puts "#{file_name}, #{index + 1}" if val == 0 }
        end
      end
    end
  end
end

SimpleCov.start 'rails' do
  add_filter '/vendor/'
  add_filter '/.bundler/'
  add_filter '/app/helpers/admin/'
  add_filter '/lib/i14y_collections.rb'
  add_filter '/app/.*/.*azure.*.rb'

  add_group 'Engines', 'app/engines'
  add_group 'API', 'app/api'
  add_group 'Concerns', 'app/concerns'
  merge_timeout 1800
end
