require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
require './lib/active_scaffold_export/version.rb'

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "active_scaffold_export"
  gem.version = ActiveScaffoldExport::Version::STRING
  gem.homepage = "http://github.com/mojotech/active_scaffold_export"
  gem.license = "MIT"
  gem.summary = %Q{Exporting Records with ActiveScaffold}
  gem.description = %Q{This Active Scaffold plugin provides a configurable CSV 'Export' action for Active Scaffold controllers}
  gem.email = "activescaffold@googlegroups.com"
  gem.authors = ["Volker Hochstein", "Mojo Tech, LLC", "see commits"]
  gem.add_runtime_dependency 'active_scaffold', '>= 3.0.12'
  if RUBY_VERSION < "1.9"
    gem.add_runtime_dependency "fastercsv"
  end
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "active_scaffold_export #{ActiveScaffoldExport::Version::STRING}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
