require 'json'

file_path = ARGV[0]
read_file = File.read(file_path)
full_report = JSON.parse(read_file)
source_files = full_report['source_files']
total_coverage = full_report['covered_percent'].round(2)

if total_coverage < 100
  puts "\n=========== Lines missing coverage: ==========="
  source_files.each do |file|
    coverage_per_file = JSON.parse(file['coverage'])
    if coverage_per_file.include? 0
      print "#{file['name']} "
      puts coverage_per_file.each_index.select{ |i| coverage_per_file[i] == 0 }.map{|line_index| line_index + 1}.join(", ")
    end
  end
  puts "\nCoverage (#{total_coverage}%) is below the expected minimum coverage (100.00%) \n\n"
  exit(1)
end