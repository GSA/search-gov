namespace :screenshots do
  task :clean do
    FileUtils.rm_rf  Dir["screenshots/report/**/*-*-*"]
    FileUtils.rm  Dir["screenshots/report/**/*.html"]
  end

  desc "" #hide from rake -T screenshots
  Spec::Rake::SpecTask.new :runtests do |t|
    t.spec_opts = ['--options', "\"#{Rails.root.join('spec', 'spec.opts')}\""]
    spec_glob = ENV["SAUCE_SPEC_GLOB"] || "screenshots/**/*_spec.rb"
    t.spec_files = FileList[spec_glob]
  end

  task :report do
    %x{haml screenshots/report/index.html.haml > screenshots/report/index.html}
    %x{open screenshots/report/index.html}
  end

  task :run do
    Rake::Task["screenshots:clean"].invoke
    Rake::Task["screenshots:runtests"].invoke
    Rake::Task["screenshots:report"].invoke
  end
end

desc "Run sauce tests, create screenshots"
task :screenshots => "screenshots:run"

