namespace :usasearch do
  task :compile_docs do
    Dir['app/views/docs/markdown/**/*'].each do |in_path|
      out_path = in_path.gsub(/\/markdown\//, '/').gsub(/\.markdown$/, '.html')
      File.open(out_path, 'w+') do |out_file|
        out_file.puts(`markdown #{in_path}`)
      end
      puts "converted #{in_path} --> #{out_path}"
    end
  end
end
