# This application artifitially persist the state in an URL
# Remember that HTTP is stateless, which means that each request is handled separately by the server.

# We basically maintain the code from the roll_dice program
# to make the program work even when no parameters are passed, we update the helper method so split is called either on a parameter or an empty string if no param is passed (line 12)
require 'socket'

def parse_request(request_line)
  http_method, path_and_params, http = request_line.split(' ')
  path, params = path_and_params.split('?')

  params = (params || '').split('&').each_with_object({}) do |pair, hash|
    key, value = pair.split('=')
    hash[key] = value
  end

  [http_method, path, params]
end

server = TCPServer.new('localhost', 3003)
loop do
  client = server.accept
  request_line = client.gets
  next if !request_line || request_line =~ /favicon/

  puts request_line

  http_method, path, params = parse_request(request_line)

  client.puts 'HTTP/1.1. 200 OK'
  client.puts 'Content-Type: text/html'
  client.puts
  client.puts '<html>'
  client.puts '<body>'
  client.puts '<pre>'
  client.puts http_method
  client.puts path
  client.puts params
  client.puts '</pre>'

  client.puts '<h1>Counter</h1>'

  number = params['number'].to_i
  client.puts "<p>The current number is #{number}.</p>"

  # this code adds two links that update the number parameters
  # notice the use of href to link to a new page where the 'number' parameter gets increased or decreased from current value
  # if no parameter is passed, number will equal 0 as empty string to_i in ruby returns 0
  client.puts "<a href='?number=#{number + 1}'>Increase by one</a>"
  client.puts "<a href='?number=#{number - 1}'>Decrease by one</a>"

  client.puts '</body>'
  client.puts '</html>'
  client.close
end
