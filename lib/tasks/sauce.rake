namespace :screenshots do
  task :clean do
    FileUtils.rm_rf  Dir["spec/screenshots/report/**/*-*-*"]
    FileUtils.rm  Dir["spec/screenshots/report/**/*.html"]
  end

  desc "" #hide from rake -T screenshots
  Spec::Rake::SpecTask.new :runtests do |t|
    t.spec_opts = ['--options', "\"#{Rails.root.join('spec', 'spec.opts')}\""]
    spec_glob = ENV["SAUCE_SPEC_GLOB"] || "spec/screenshots/**/*_spec.rb"
    t.spec_files = FileList[spec_glob]
  end

  task :report do
    %x{haml spec/screenshots/report/index.html.haml > spec/screenshots/report/index.html}
    %x{open spec/screenshots/report/index.html}
  end

  task :run do
    Rake::Task["screenshots:clean"].invoke
    Rake::Task["screenshots:runtests"].invoke
    Rake::Task["screenshots:report"].invoke
  end
end

desc "Run sauce tests, create screenshots"
task :screenshots => "screenshots:run"

