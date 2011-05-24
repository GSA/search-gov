require 'cucumber/rake/task' #I have to add this
require 'rspec/core/rake_task'

namespace :rcov do

  RSpec::Core::RakeTask.new(:rspec_aggregate) do |task|
    task.rcov = true
    task.pattern = 'spec/**/*_spec.rb'
    task.rcov_opts = %w{--rails --include views -Ispec --exclude gems/,spec/,features/,seeds/,.bundler --aggregate tmp/coverage.data}
    task.rspec_opts = "-c"
  end

  Cucumber::Rake::Task.new(:cucumber_aggregate) do |task|
    task.rcov = true
    task.rcov_opts = "--exclude osx/objc,gems/,spec/,features/,.bundler --rails --aggregate tmp/coverage.data -o 'coverage'"
  end

  task :clean_aggregate do
    rm "tmp/coverage.data" if File.exist?("tmp/coverage.data")
  end

  desc "Run aggregate coverage from rspec and cucumber"
  task :all => ["rcov:clean_aggregate", "rcov:rspec_aggregate", "rcov:cucumber_aggregate"]

end
