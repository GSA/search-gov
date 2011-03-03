namespace :screenshots do
  task :clean do
    FileUtils.rm_rf  Dir["screenshots/report/**/*-*-*"]
    FileUtils.rm  Dir["screenshots/report/**/*.html"]
  end

  desc "" #hide from rake -T screenshots
  Spec::Rake::SpecTask.new :runtests_spec do |t|
    t.spec_opts = ['--options', "\"#{Rails.root.join('spec', 'spec.opts')}\""]
    spec_glob = ENV["SAUCE_SPEC_GLOB"] || "screenshots/**/*_spec.rb"
    t.spec_files = FileList[spec_glob]
  end

  task :runtests_parallel do
    %x{ruby screenshots/parallel_sauce.rb}
  end

  task :runtests => :runtests_parallel

  task :report do
    %x{haml screenshots/report/index.html.haml > screenshots/report/index.html}
    %x{open screenshots/report/index.html}
  end

  task :push do
    require 'cloudfiles'
    cf = CloudFiles::Connection.new(:username => "lorensiebert", :api_key => "***REMOVED***")
    container = cf.container('SauceLabs Reports')

    Dir["screenshots/report/**/*.png"].each do |filename|
      image_obj = container.create_object filename.split('/')[-2..-1].join("/"), false
      image_obj.write(open(filename))
      puts image_obj.public_url
    end

    logo_obj = container.create_object "logo.gif", false
    logo_obj.write(open('screenshots/report/logo.gif'))

    js_obj = container.create_object "jquery-1.5.min.js", false
    js_obj.write(open('screenshots/report/jquery-1.5.min.js'))

    obj = container.create_object "saucelabs.html", false
    obj.write(open('screenshots/report/index.html'))

    puts obj.public_url
  end

  task :run do
    Rake::Task["screenshots:clean"].invoke
    Rake::Task["screenshots:runtests"].invoke
    Rake::Task["screenshots:report"].invoke
  end
end

desc "Run sauce tests, create screenshots"
task :screenshots => "screenshots:run"

