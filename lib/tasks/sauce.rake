namespace :screenshots do
  task :clean do
    FileUtils.rm "spec/screenshots/screenshots/index.html", :force => true
    FileUtils.rm Dir["spec/screenshots/screenshots/*.png"]
  end

  desc "" #hide from rake -T screenshots
  Spec::Rake::SpecTask.new :runtests do |t|
    t.spec_opts = ['--options', "\"#{Rails.root.join('spec', 'spec.opts')}\""]
    spec_glob = ENV["SAUCE_SPEC_GLOB"] || "spec/screenshots/**/*_spec.rb"
    t.spec_files = FileList[spec_glob]
  end

  task :report do
    %x{haml spec/screenshots/screenshots/index.html.haml > spec/screenshots/screenshots/index.html}
    %x{open spec/screenshots/screenshots/index.html}
  end

  task :run do
    Rake::Task["screenshots:clean"].invoke
    Rake::Task["screenshots:runtests"].invoke
    Rake::Task["screenshots:report"].invoke
  end
end

desc "Run sauce tests, create screenshots"
task :screenshots => "screenshots:run"

