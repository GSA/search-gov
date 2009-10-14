Apache Log Parser
=========

Parsing apache log library for rails.

Example
=======

h4. parse one line

  log = Apache::Log::Combined.parse '127.0.0.1 - - [25/Sep/2008:08:48:38 +0900] "GET /index.html HTTP/1.1" 200 45 "http://localhost/sample.html" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"'

  puts log.remote_ip    # => "127.0.0.1"
  puts log.time         # => "Thu Sep 25 08:48:38 +0900 2008"

h4. parse file

  Apache::LogFile.foreach( "access.log", :format => :combined, :cache => true ) { |log|
    puts log.time
  }

Copyright (c) 2009 Beyond, released under the MIT license
