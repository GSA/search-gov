require 'mechanize'
require 'time'

class BitlyAPI
  INFO_URL = 'http://api.bit.ly/v3/info'
  EXPAND_URL = 'http://api.bit.ly/v3/expand'
  MAX_INFO_BATCH_SIZE = 10
  MAX_EXPAND_BATCH_SIZE = 10

  COLUMN_MAP = {}
  [ :rank, nil, nil, nil, nil, nil, nil, :clicks, :short_url, :long_url, :title, :trend ].each_with_index { |item,  index|
	  COLUMN_MAP[item] = index unless item.nil?
  }
  
  attr_accessor :bitly_map, :username, :password, :api_key
  
  def initialize(options = {})
    @username = options[:username]
    @password = options[:password]
    @api_key = options[:api_key]
    @browser = Mechanize.new
    @browser.pluggable_parser.csv = CSVFileSaver
  end
  
  def grab_csv_for_date(date = Date.yesterday)
    csv_file_name = "allday-#{date.strftime("%Y%m%d-%H%M")}.csv"
    if File.exist?( csv_file_name )
      File.delete(csv_file_name)
    end
    sign_in unless signed_in?
    csv_url = "http://bit.ly/pro/visited?hour-selector=all-day&ts=#{date.to_time.to_i}&resolution=day&export_type=csv&export=true"
    csv = @browser.get(csv_url)
    temp_file_path = File.join(Rails.root.to_s, "tmp", csv_file_name)
    File.open(temp_file_path, "w" ){ |csv_file| csv_file.write( csv.csv_body) }
    temp_file_path
  end
  
  def parse_csv(csv_file_name)
    info_urls = []
    expand_urls = []
    leish = 1000
    hashes = []
    @bitly_map = {}
    report_title = nil
    CSV.foreach(csv_file_name) do |row|
      case row.size 
        when 2 :
	        report_title = row[1]
        when 12 :
	        unless row[0].nil? || (row[0].to_i rescue 0) == 0
		        rank = row[COLUMN_MAP[:rank]].to_i
		        title = CGI::unescapeHTML(row[COLUMN_MAP[:title]].to_s) rescue nil
		        clicks = row[COLUMN_MAP[:clicks]].to_i 
		        short_url = row[COLUMN_MAP[:short_url]]
		        long_url = row[COLUMN_MAP[:long_url]].to_s rescue nil
		        if title.nil? || title.empty?
			        info_urls << short_url
		        end
		        if long_url.nil? || long_url.empty?
			        expand_urls << short_url
		        end
 		        hashes << short_url
		        @bitly_map[short_url] = { :long_url => long_url, :title => title, :clicks => clicks }
		        leish -= 1
	        end
        end
      break if leish <= 0
    end

    unless info_urls.empty?
      batch_info_query( info_urls ).each { |hash, hash_info|
	      @bitly_map[hash].merge!( hash_info )
      }
    end

    unless expand_urls.empty?
      batch_expand_query( expand_urls ).each { |hash, hash_info|
	      @bitly_map[hash].merge!( hash_info )
      }
    end    
  end
  
  def get_popular_links_for_domain(domain)
    results = []
    @bitly_map.keys.each do |short_url|
      link = @bitly_map[short_url][:long_url]
      results << @bitly_map[short_url] if domain_for_link(link) == domain
    end
    results
  end
  
  def signed_in?
    @signed_in
  end  
  
  def sign_in
    unless @signed_in
      home_page = @browser.get('http://bit.ly/')
      sign_in_page = @browser.click(home_page.link_with(:text => /Sign In/))
      signed_in_page = sign_in_page.form_with(:action => '/a/sign_in') do |f|
        f.field_with(:name => 'username').value = @username
        f.field_with(:name => 'password').value = @password
      end.click_button
      @signed_in = true
    end
  end
  
  private
  
  def remote_batch_info_query( short_urls )
		bitly_batch_info = {}
		until short_urls.nil? || short_urls.empty? do
			batch_urls = short_urls[ 0 .. (MAX_INFO_BATCH_SIZE-1) ]
			short_urls = short_urls[ MAX_INFO_BATCH_SIZE .. -1 ]
			query = "#{INFO_URL}?login=#{@username}&apiKey=#{@api_key}" 
			batch_urls.each_with_index { |short_url, url_index| query << "&hash=#{short_url}" }
			response = JSON.parse RestClient.get(query)
			raise "Bitly error: #{response['status_txt']}" unless response['status_code'] == 200
			response['data']['info'].each { |url_info|
				hash = url_info['hash']
				info_map = {}
				url_info.each { |name, value| 
					info_map[name.to_sym] = value unless name == 'hash' || name == 'user_hash' || name == 'global_hash'
				}
				bitly_batch_info[hash] = info_map
			} if response['data']
		end
		return bitly_batch_info
 	end

	def batch_info_query( short_urls )
		return remote_batch_info_query( short_urls )
	end
	
	def remote_batch_expand_query( short_urls )
		bitly_batch_info = {}
		until short_urls.nil? || short_urls.empty? do
			batch_urls = short_urls[ 0 .. (MAX_EXPAND_BATCH_SIZE-1) ]
			short_urls = short_urls[ MAX_EXPAND_BATCH_SIZE .. -1 ]
			query = "#{EXPAND_URL}?login=#{@username}&apiKey=#{@api_key}" 
			batch_urls.each_with_index { |short_url, url_index| query << "&hash=#{short_url}" }
			response = JSON.parse RestClient.get(query)
			raise "Bitly error: #{response['status_txt']}" unless response['status_code'] == 200
			response['data']['expand'].each { |url_info|
				hash = url_info['hash']
				info_map = {}
				url_info.each { |name, value| 
					info_map[name.to_sym] = value unless name == 'hash' || name == 'user_hash' || name == 'global_hash'
				}
				bitly_batch_info[hash] = info_map
			}
		end
		return bitly_batch_info
 	end

	def batch_expand_query( short_urls )
		return remote_batch_expand_query( short_urls )
	end
	
	def domain_for_link(link)
	  host = link.gsub("http://", "").gsub("https://", "").gsub( /[\/?].*/, "")
	  domain = host.split(".")[-2..-1].join(".") rescue host
	end
end

class CSVFileSaver < Mechanize::File
  attr_reader :csv_body
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    super(uri, response, body, code)
    @csv_body = body
  end
end