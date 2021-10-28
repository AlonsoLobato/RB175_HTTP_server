# require the socket Ruby library
require "socket"

# create a TCP Server for connection
# we'll build our server on top of it
# note how it takes hostname and port as arguments, which specifies where the server
# would accept requests.

server = TCPServer.new("localhost", 3003)
# the loop executes the application code in loops until the program exits or the process running inside stops
loop do
  client = server.accept # '.accept' is an TCPServer method that accepts an incomming connection and returns a TCPSocket obj; we store it in a local var

  request_line = client.gets # '.gets' is a Kernel method that captures the first line of whatever the HTTP request is (method + path + scheme -> GET / HTTP/1.1)
  puts request_line # this line prints the captured first line to the terminal

  client.puts "HTTP/1.1 200 OK\r\n\r\n"
  client.puts request_line # and finally this line sends the same string to the user for display
  client.close
end
