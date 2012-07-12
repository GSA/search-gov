require 'socket'

def local_ip
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

  socket = UDPSocket.new
  socket.connect '64.233.187.99', 1
  socket.addr.last
ensure
  Socket.do_not_reverse_lookup = orig
end
HERNDON = "***REMOVED***"
CHICAGO = "***REMOVED***"
SERVER_LOCATION = local_ip =~ /^192.168.110/ ? HERNDON : CHICAGO