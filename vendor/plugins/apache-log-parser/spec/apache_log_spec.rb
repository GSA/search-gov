require File.join(File.dirname(__FILE__),'spec_helper')

$most_simply_combinded_log = '- - - [25/Sep/2008:08:48:38 +0900] "" - - "-" "-"'

# typicality of combined apache log
$normal_load_log = '127.0.0.1 - - [25/Sep/2008:08:48:38 +0900] "GET /index.html HTTP/1.1" 200 45 "http://localhost/sample.html" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"'

# typicality of combined apache log
$normal_load_log_tsv = '127.0.0.1	-	-	[25/Sep/2008:08:48:38 +0900]	"GET /index.html HTTP/1.1"	200	45	"http://localhost/sample.html"	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"'

# example logs for parsing difficulty
# http://d.hatena.ne.jp/edry/20080925
$rough_road_log = <<'END'
127.0.0.1	-	user	[25/Sep/2008:08:48:38 +0900]	"GET /index.html HTTP/1.1"	200	45	"http://localhost/sample.html"	"Firefox/3.0.1"
127.0.0.1	-	- space [date]	[25/Sep/2008:08:56:37 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
127.0.0.1	-	user	[25/Sep/2008:09:03:19 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
127.0.0.1	-	- space [date]	[25/Sep/2008:09:04:37 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
127.0.0.1	-	[\"][\\][\t]	[25/Sep/2008:09:04:40 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
localhost	-	-	[25/Sep/2008:09:13:02 +0900]	"GET / HTTP/1.1"	200	99	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
az9<!$%&=|'~^`+-*/_,.;:@?>(\"){\\}[]	-	-	[25/Sep/2008:09:14:54 +0900]	"GET / HTTP/1.1"	200	99	"-"	"-"
127.0.0.1	-	-	[25/Sep/2008:09:15:15 +0900]	"GET / HTTP/1.1"	200	99	"-"	"-"
a	-	-	[25/Sep/2008:09:16:02 +0900]	"GET / HTTP/1.1"	501	272	"-"	"-"
a\x1ba	-	-	[25/Sep/2008:09:17:21 +0900]	"GET / HTTP/1.1"	200	99	"-"	"-"
localhost	unknown	-	[25/Sep/2008:09:25:18 +0900]	"GET / HTTP/1.1"	200	524	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
localhost	edry	-	[25/Sep/2008:09:35:34 +0900]	"GET / HTTP/1.1"	200	99	"-"	"-"
localhost	ar	-	[25/Sep/2008:09:38:39 +0900]	"GET / HTTP/1.1"	200	99	"-"	"-"
localhost	aZ9<!#$%&=|'~^`+-*/_,.;:@?>(\"){\\}[]	-	[25/Sep/2008:09:40:51 +0900]	"GET / HTTP/1.1"	200	99	"-"	"-"
localhost	unknown	-	[25/Sep/2008:09:44:49 +0900]	"GET / HTTP/1.1"	200	99	"-"	"-"
localhost	\x1b	-	[25/Sep/2008:09:46:23 +0900]	"GET / HTTP/1.1"	200	99	"-"	"-"
localhost	ident	user	[25/Sep/2008:10:00:39 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
localhost	ident	aZ9<!#$%&=|'~^`+-*/_,.;	[25/Sep/2008:10:04:30 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
localhost	ident	aZ9<!#$%&=|'~^`+-*/_,.;@?>(\"){\\}[tab\t][space ]	[25/Sep/2008:10:06:22 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
localhost	ident	""	[25/Sep/2008:10:10:37 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
localhost	ident	user	[25/Sep/2008:10:23:50 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"-"	"-"
localhost	ident	\n	[25/Sep/2008:10:25:37 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"-"	"-"
localhost	ident	aZ9<!#$%&=|'~^`+-*/_,.;:@?>(\"){\\}[tab][space ]	[25/Sep/2008:10:39:39 +0900]	"GET /digest HTTP/1.1"	401	469	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
localhost	ident	\t	[25/Sep/2008:10:47:29 +0900]	"GET /digest/index.html HTTP/1.1"	400	294	"-"	"-"
localhost	ident	- [25/Sep/2008:10:47:29 +0900] localhost ident - [25/Sep/2008:10:47:29 +0900] ident -	[25/Sep/2008:10:55:20 +0900]	"GET /digest HTTP/1.1"	401	469	"-"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
localhost	ident	-	[01/Jan/1970:09:00:04 +0900]	"GET / HTTP/1.1"	200	99	"-"	"-"
localhost	ident	-	[01/Jan/2038:00:00:11 +0900]	"GET / HTTP/1.1"	200	99	"-"	"-"
localhost	ident	-	[25/Sep/2008:11:10:26 +0900]	"aZ9<!#$%&=|'~^`+-*/_,.;:@?>(\"){\\}[tab\t][space ]"	400	295	"-"	"-"
localhost	ident	-	[25/Sep/2008:11:11:18 +0900]	""	501	271	"-"	"-"
localhost	ident	-	[25/Sep/2008:11:15:13 +0900]	"GET /asis.asis HTTP/1.1"	777	93	"-"	"-"
localhost	ident	-	[25/Sep/2008:11:17:44 +0900]	"GET /asis.asis HTTP/1.1"	-	93	"-"	"-"
localhost	ident	-	[25/Sep/2008:11:20:24 +0900]	"GET /asis.asis HTTP/1.1"	2147483647	93	"-"	"-"
localhost	ident	-	[25/Sep/2008:11:22:47 +0900]	"HEAD / HTTP/1.1"	200	-	"-"	"-"
localhost	ident	-	[25/Sep/2008:11:29:41 +0900]	"GET /omotai.txt HTTP/1.0"	200	2306867200	"-"	"Wget/1.10.2"
localhost	ident	-	[25/Sep/2008:11:34:59 +0900]	"GET / HTTP/1.1"	200	2	"aZ9<!#$%&=|'~^`+-*/_,.;:@?>(\"){\\}[tab\t][space ]"	"-"
localhost	ident	-	[25/Sep/2008:11:35:47 +0900]	"GET / HTTP/1.1"	200	2	""	"-"
localhost	ident	-	[25/Sep/2008:11:37:52 +0900]	"GET / HTTP/1.1"	200	2	"-"	"aZ9<!#$%&=|'~^`+-*/_,.;:@?>(\"){\\}[tab\t][space ]"
localhost	ident	-	[25/Sep/2008:11:38:58 +0900]	"GET / HTTP/1.1"	200	2	"-"	""
127.0.0.1	-	-	[25/Sep/2008:12:44:26 +0900]	"GET /basic/index.html HTTP/1.1"	401	469	"http://www.example.com/"	"Mozilla/5.0 (X11; U; Linux i686; ja; rv:1.9.0.1) Gecko/2008072820 Firefox/3.0.1"
END


describe :apache_log do
	describe Apache::Log::Combined do
		describe "creation" do
			it "should allow parsed log data array" do
				input = [ "127.0.0.1", nil, nil, Time.utc( 2008, 9, 24, 23, 48, 38 ), "GET", "/index.html", "HTTP/1.1", 200, 45, "http://localhost/sample.html", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)" ]
				log = Apache::Log::Combined.new( input )

				log.remote_ip.should == "127.0.0.1"
				log.user.should be_nil
				log.time.should == Time.utc( 2008, 9, 24, 23, 48, 38 )
				log.to_s.should == $normal_load_log
			end

			it "should allow non parsed splitted log data array" do
				input = [ "127.0.0.1", "-", "-", "25/Sep/2008:08:48:38 +0900", "GET", "/index.html", "HTTP/1.1", "200", "45", "http://localhost/sample.html", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)" ]
				log = Apache::Log::Combined.new( input )

				log.remote_ip.should == "127.0.0.1"
				log.user.should be_nil
				log.time.should == Time.utc( 2008, 9, 24, 23, 48, 38 )
				log.to_s.should == $normal_load_log
			end

			it "should create with no argument" do
				a = Apache::Log::Combined.new
				a.should_not be_nil
			end

			it "should throw ArgumentError less than 11 args" do
				lambda{ Apache::Log::Combined.new( [ 1, 2 ] ) }.should raise_error( ArgumentError )
			end
		end
	end

	it "should be able to parse for typicality of combined apache log" do
		parsed = Apache::Log::Combined.parse( $normal_load_log )
		parsed[0].should == "127.0.0.1"
		parsed[1].should == "-"
		parsed[2].should == "-"
		parsed[3].should == "25/Sep/2008:08:48:38 +0900"
		parsed[4].should == "GET"
		parsed[5].should == "/index.html"
		parsed[6].should == "HTTP/1.1"
		parsed[7].should == "200"
		parsed[8].should == "45"
		parsed[9].should == "http://localhost/sample.html"
		parsed[10].should == "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"

		parsed.remote_ip.should == "127.0.0.1"
		parsed.ident.should     == nil
		parsed.user.should      == nil
		parsed.time.utc.should  == Time.utc( 2008, 9, 24, 23, 48, 38 )
		parsed.method.should    == "GET"
		parsed.path.should      == "/index.html"
		parsed.protocol.should  == "HTTP/1.1"
		parsed.status.should    == 200
		parsed.size.should      == 45
		parsed.referer.should   == "http://localhost/sample.html"
		parsed.agent.should     == "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"
		parsed.appendix.should be_nil

		to_a = parsed.to_a
		to_a[0].should == "127.0.0.1"
		to_a[1].should be_nil
		to_a[2].should be_nil
		to_a[3].should == Time.utc( 2008, 9, 24, 23, 48, 38 )
		to_a[4].should == "GET"
		to_a[5].should == "/index.html"
		to_a[6].should == "HTTP/1.1"
		to_a[7].should == 200
		to_a[8].should == 45
		to_a[9].should == "http://localhost/sample.html"
		to_a[10].should == "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"
		to_a[11].should be_nil
	end

	it "should make combined apache log" do
		parsed = Apache::Log::Combined.parse( $normal_load_log )
		parsed.to_s.should == $normal_load_log
	end

	it "should allow appendix" do
		parsed = Apache::Log::Combined.parse( $normal_load_log + " aaa bbb" )
		parsed[0].should == "127.0.0.1"
		parsed[1].should == "-"
		parsed[2].should == "-"
		parsed[3].should == "25/Sep/2008:08:48:38 +0900"
		parsed[4].should == "GET"
		parsed[5].should == "/index.html"
		parsed[6].should == "HTTP/1.1"
		parsed[7].should == "200"
		parsed[8].should == "45"
		parsed[9].should == "http://localhost/sample.html"
		parsed[10].should == "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"
		parsed[11].should == "aaa bbb"

		parsed.remote_ip.should == "127.0.0.1"
		parsed.ident.should     == nil
		parsed.user.should      == nil
		parsed.time.utc.should  == Time.utc( 2008, 9, 24, 23, 48, 38 )
		parsed.method.should    == "GET"
		parsed.path.should      == "/index.html"
		parsed.protocol.should  == "HTTP/1.1"
		parsed.status.should    == 200
		parsed.size.should      == 45
		parsed.referer.should   == "http://localhost/sample.html"
		parsed.agent.should     == "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"
		parsed.appendix.should  == "aaa bbb"
	end

	it "should make combined apache log with appendix" do
		parsed = Apache::Log::Combined.parse( $normal_load_log + " aaa bbb" )
		parsed.to_s.should == $normal_load_log + " aaa bbb"
	end

	it "should allow appendix on tsv" do
		parsed = Apache::Log::Combined.parse( $normal_load_log_tsv + "	aaa	bbb", :tab )
		parsed[0].should == "127.0.0.1"
		parsed[1].should == "-"
		parsed[2].should == "-"
		parsed[3].should == "25/Sep/2008:08:48:38 +0900"
		parsed[4].should == "GET"
		parsed[5].should == "/index.html"
		parsed[6].should == "HTTP/1.1"
		parsed[7].should == "200"
		parsed[8].should == "45"
		parsed[9].should == "http://localhost/sample.html"
		parsed[10].should == "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"
		parsed[11].should == "aaa	bbb"

		parsed.remote_ip.should == "127.0.0.1"
		parsed.ident.should     == nil
		parsed.user.should      == nil
		parsed.time.utc.should  == Time.utc( 2008, 9, 24, 23, 48, 38 )
		parsed.method.should    == "GET"
		parsed.path.should      == "/index.html"
		parsed.protocol.should  == "HTTP/1.1"
		parsed.status.should    == 200
		parsed.size.should      == 45
		parsed.referer.should   == "http://localhost/sample.html"
		parsed.agent.should     == "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"
		parsed.appendix.should  == "aaa	bbb"

		to_a = parsed.to_a
		to_a[0].should == "127.0.0.1"
		to_a[1].should be_nil
		to_a[2].should be_nil
		to_a[3].should == Time.parse( "25/Sep/2008 08:48:38 +0900" )
		to_a[4].should == "GET"
		to_a[5].should == "/index.html"
		to_a[6].should == "HTTP/1.1"
		to_a[7].should == 200
		to_a[8].should == 45
		to_a[9].should == "http://localhost/sample.html"
		to_a[10].should == "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"
		to_a[11].should == "aaa	bbb"
	end

	$rough_road_log.lines.each_with_index { |tsv_line, i|
	  it "should be able to parse space delimitted log format:#{i+1}" do
				tsv_line.strip!
				prepared = tsv_line.split( "\t" )
				line = prepared.join " "
				parsed = Apache::Log::Combined.parse( line ).dup
				prepared[3] = prepared[3][1...-1]
				prepared[4] = prepared[4][1...-1]
				prepared[7] = prepared[7][1...-1]
				prepared[8] = prepared[8][1...-1]
				parsed[4,3] = parsed[ 4, 3 ].compact.join( " " )
				parsed.should == prepared
	  end
	}

	$rough_road_log.lines.each_with_index { |tsv_line, i|
	  it "should be able to parse tab delimitted log format:#{i+1}" do
				tsv_line.strip!
				prepared = tsv_line.split( "\t" )
				line = tsv_line
				parsed = Apache::Log::Combined.parse( line, :tab ).dup
				prepared[3] = prepared[3][1...-1]
				prepared[4] = prepared[4][1...-1]
				prepared[7] = prepared[7][1...-1]
				prepared[8] = prepared[8][1...-1]
				parsed[4,3] = parsed[ 4, 3 ].compact.join( " " )
				parsed.should == prepared
	  end
	}

	describe :LogFile do
		describe :read do
			it "should read all lines" do
				logs = Apache::LogFile.read( "spec/test.log" )
				logs.size.should == 2
			end

			it "should support only combined log format yet" do
				lambda { Apache::LogFile.read( "spec/test.log", :format => :combined ) }.should_not raise_error( ArgumentError )
				lambda { Apache::LogFile.read( "spec/test.log", :format => :common ) }.should raise_error( ArgumentError )
			end
		end

		describe :foreach do
			it "should read each line" do
				i = 0
				logs = Apache::LogFile.foreach( "spec/test.log" ) { |x|
					i += 1
					x.class.should == Apache::Log::Combined
				}
				i.should == 2
			end

			describe "for tsv log" do
				it "should read each line" do
					i = 0
					logs = Apache::LogFile.foreach( "spec/test_tsv.log", :tab ) { |x|
						i += 1
						x.class.should == Apache::Log::Combined
					}
					i.should == 2
				end
			end
		end
	end

	after do
		File.delete "spec/test.cache" rescue nil 
		File.delete "spec/test_tsv.cache" rescue nil
	end

	describe "io parser" do
		it "should read file and parsing" do
		end
	end
end
