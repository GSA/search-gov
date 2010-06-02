# ApacheLog
require "active_support"

module Apache
	LogFormats = {
		:combined => %r'^(.*?) (.*?) (.*) \[(.*?)\] "(.*?)(?:\s+(.*?)\s+(\S*?))?" (.*?) (.*?) "(.*?)" "(.*?)"(?: (.*))?$',
		:common => %r'^(.*?) (.*?) (.*) \[(.*?)\] "(.*?)(?:\s+(.*?)\s+(\S*?))?" (.*?) (.*?)$',
		:path => %r'^"(.*?)(?:\s+(.*?)\s+(\S*?))?"$',
		:date => %r"^(.*?)\/(.*?)\/(.*?):(.*?):(.*?):(.*?)( ([\+-])(\d\d)(\d\d))?$"
	}

	Month = { "Jan" => 1, "Feb" => 2, "Mar" => 3, "Apr" => 4,
						"May" => 5, "Jun" => 6, "Jul" => 7, "Aug" => 8,
						"Sep" => 9, "Oct" => 10, "Nov" => 11, "Dec" => 12
					}

	module Log
	  class Common < Array
	    attr_accessor :remote_ip, :ident, :user, :time, :path, :status, :size
			attr_accessor :method, :protocol
      
			def initialize( args=nil )
				return if args.blank?

				raise ArgumentError.new( "wrong number of arguments (#{args.size} for over 8)" ) if args.size < 8
				if args.last
					super
				else
					super args[0...-1]
				end

				@remote_ip, @ident, @user, timestr, 
						@method, @path, @protocol, @status, @size = *args

				@ident = nil if @ident == "-"
				@user  = nil if @user == "-"
				@status = @status == "-" ? nil : @status.to_i
				@size = @size == "-" ? nil : @size.to_i
				if timestr.class == String
					@time = parse_time( timestr )
				else
					@time = timestr
				end
			end
			
			def to_a
				result = [
					remote_ip,
					ident,
					user,
					time,
					method,
					path,
					protocol,
					status,
					size
				]
				result
			end

			def parse_time( timestr )
				if timestr =~ LogFormats[ :date ]
					time = Time.gm( $3.to_i, Month[ $2 ], $1.to_i, $4.to_i, $5.to_i, $6.to_i )

					if $8 == '+'
						time -=  $9.to_i * 60 * 60
						time -= $10.to_i * 60
					elsif $8 == '-'
						time +=  $9.to_i * 60 * 60
						time += $10.to_i * 60
					end
					time
				end
			end

			class <<self
				def parse( line, delimiter = :space )
					if delimiter == :space
						m = LogFormats[:common].match( line )
						if m
							Common.new( m.to_a[ 1..-1 ] )
						else
							nil
						end
					elsif delimiter == :tab
						x = line.split( "\t", 10 )
						x[3] = x[3][1...-1]
						x[7] = x[7][1...-1]
						x[8] = x[8][1...-1]
						paths = LogFormats[ :path ].match( x[4] )
						x[4,1] = paths[ 1..-1 ]
						Combined.new( x )
					end
				end
			end

			def to_s( delimiter = :space )
				a = []
				a << ( remote_ip ? remote_ip : "-" )
				a << ( ident ? ident : "-" )
				a << ( user ? user : "-" )
				a << "[" + time.localtime.strftime( "%d/%b/%Y:%H:%M:%S %z" ) + "]"
				a << '"' + [ method ? method : "GET", path, protocol ].compact.join( " " ) + '"'
				a << ( status ? status : "-" )
				a << ( size ? size : "-" )

				if delimiter == :space
					a.join( " " )
				else
					a.join( "\t" )
				end
			end
		end
	  
		class Combined < Array
			attr_accessor :remote_ip, :ident, :user, :time, :path, :status, :size
			attr_accessor :method, :protocol, :referer, :agent, :appendix

			def initialize( args=nil )
				return if args.blank?

				raise ArgumentError.new( "wrong number of arguments (#{args.size} for over 11)" ) if args.size < 11
				if args.last
					super
				else
					super args[0...-1]
				end

				@remote_ip, @ident, @user, timestr, 
						@method, @path, @protocol, @status, @size, @referer, @agent, @appendix = *args

				@ident = nil if @ident == "-"
				@user  = nil if @user == "-"
				@referer = nil if @referer == "-"
				@agen    = nil if @agent == "-"
				@status = @status == "-" ? nil : @status.to_i
				@size = @size == "-" ? nil : @size.to_i
				if timestr.class == String
					@time = parse_time( timestr )
				else
					@time = timestr
				end
			end

			def to_a
				result = [
					remote_ip,
					ident,
					user,
					time,
					method,
					path,
					protocol,
					status,
					size,
					referer,
					agent,
				]
				result << appendix if appendix
				result
			end

			def parse_time( timestr )
				if timestr =~ LogFormats[ :date ]
					time = Time.gm( $3.to_i, Month[ $2 ], $1.to_i, $4.to_i, $5.to_i, $6.to_i )

					if $8 == '+'
						time -=  $9.to_i * 60 * 60
						time -= $10.to_i * 60
					elsif $8 == '-'
						time +=  $9.to_i * 60 * 60
						time += $10.to_i * 60
					end
					time
				end
			end

			class <<self
				def parse( line, delimiter = :space )
					if delimiter == :space
						m = LogFormats[:combined].match( line )
						if m
							Combined.new( m.to_a[ 1..-1 ] )
						else
							nil
						end
					elsif delimiter == :tab
						x = line.split( "\t", 10 )
						x[3] = x[3][1...-1]
						x[7] = x[7][1...-1]
						x[8] = x[8][1...-1]
						paths = LogFormats[ :path ].match( x[4] )
						x[4,1] = paths[ 1..-1 ]
						Combined.new( x )
					end
				end
			end

			def to_s( delimiter = :space )
				a = []
				a << ( remote_ip ? remote_ip : "-" )
				a << ( ident ? ident : "-" )
				a << ( user ? user : "-" )
				a << "[" + time.localtime.strftime( "%d/%b/%Y:%H:%M:%S %z" ) + "]"
				a << '"' + [ method ? method : "GET", path, protocol ].compact.join( " " ) + '"'
				a << ( status ? status : "-" )
				a << ( size ? size : "-" )
				a << '"' + ( referer ? referer : "-" ) + '"'
				a << '"' + ( agent ? agent : "-" ) + '"'
				a << @appendix if @appendix

				if delimiter == :space
					a.join( " " )
				else
					a.join( "\t" )
				end
			end
		end
	end

end
