require 'net/http'
require 'cgi'

namespace :usasearch do
  namespace :validate do

    desc "validate HTML generated for affiliate searches"
    task :all => :environment do
      raise "Usage: rake usasearch:validate:all HOST=127.0.0.1:3000 QUERY=government" unless ENV["HOST"] and ENV["QUERY"]
      host = ENV["HOST"]
      query = URI.encode(ENV["QUERY"])
      count=0
      base_url = "http://#{host}/search?query=#{query}&affiliate="
      Affiliate.find(:all, :order => "name").each do |affiliate|
        url = "#{base_url}#{affiliate.name}"
        puts "\n::::::::::::::::::::::::::::::::::::::::::\nChecking #{affiliate.name} at #{url}"
        puts "#{affiliate.name} isn't using a header or footer so it should be OK" if affiliate.header.blank? and affiliate.footer.blank?
        res = Net::HTTP.get_response(URI::parse(url))
        fname = "/tmp/#{affiliate.name}.html"
        File.open(fname, 'w') do |f|
          f.write res.body
          f.close
          system "xmllint --html --noout #{fname} 2>&1"
        end
        count+=1
      end
      puts "\nChecked #{count} affiliates for HTML validation with this query: #{query}"
    end

  end
end