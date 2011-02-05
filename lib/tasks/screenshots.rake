task :screenshots do
  FileUtils.rm "spec/selenium/screenshots/index.html", :force => true
  FileUtils.rm Dir["spec/selenium/screenshots/*.png"]

  Rake::Task["spec:selenium:sauce"].invoke

  %x{haml spec/selenium/screenshots/index.html.haml > spec/selenium/screenshots/index.html}
  %x{open spec/selenium/screenshots/index.html}
end
