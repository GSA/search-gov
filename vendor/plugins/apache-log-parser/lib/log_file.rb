module Apache
	class LogFile
		def open( *args, &block )
			a = LogFile.new( args )
			block.call( a ) if block
		end

		class <<self
			def read( *args )
				result = []
				foreach( *args ) { |x|
					result << x
				}
	
				result
			end

			def foreach( *args )
				options = args.extract_options!
				fname = args[0]
				delimiter = args[1] || :space
				format = options[ :format ] || :combined
				if format == :combined
					format = Apache::Log::Combined
				elsif format == :common
				  format = Apache::Log::Common
				else
					raise ArgumentError.new( "Invalid log format" )
				end
				cached = options[ :cached ] || false

				if cached == true
					dirname = File.dirname( fname )
					basename = File.basename( fname, ".*" )
					cache_name = File.join( dirname, basename + ".cache" )
				end

				if cache_name && File.exist?( cache_name ) && File.mtime( cache_name ) >= File.mtime( fname )
					port = File.open( cache_name )
					begin
						format, = Marshal.load( port ) rescue nil
						while( !port.eof )
							yield format.new( Marshal.load( port ) )
						end
					ensure
						port.close
					end
				else
					begin
						if cache_name
							cache_file = File.open( cache_name, "w" ) 
							Marshal.dump( [ format ], cache_file )
						end
						File.foreach( fname ) { |line|
							line.chomp!
							log = format.parse( line, delimiter )
							yield log if log
							Marshal.dump( log.to_a, cache_file ) if cache_name
						}
					ensure
						cache_file.close if cache_name
					end
				end

				self
			end
		end

		def read
		end
	end
end
