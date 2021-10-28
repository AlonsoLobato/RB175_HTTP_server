# This programs manually handles a text-based request-response cycle
# with the request coming from user via URL entered into a browser (including some query strings)
# and a response being handled by the server with some ruby and html code.

# This application rolls a number of dices with different number of sides
# the information is passed to the server using the URL with parameters (query parameters)

#==================================================================#

# required library (default by Ruby) that includes a bunch of classes we can use to interact with servers and other networking tasks
require 'socket'

# helper method created to parse the HTTP request line ("GET /?rolls=2&sides=6 HTTP/1.1") into different parts we need to interact with at the server
def parse_request(request_line)
  http_method, path_and_params, http = request_line.split(' ') # uses the spaces in the HTTP request line to divide into three: method, path, scheme
  path, params = path_and_params.split('?') # uses the '?' in the path to separate the path and params

  params = params.split('&').each_with_object({}) do |pair, hash| # uses the '&' to create a hash where keys are the param names and vals are the params values
    key, value = pair.split('=')
    hash[key] = value
  end

  [http_method, path, params] # return values from the method is an array with the three main parts of the HTTP request (this is a pretty standard structure)
end

server = TCPServer.new('localhost', 3003) # instantiating an object of TCP server class, passing two arguments, the server name and the port
loop do # main Ruby code in the application
  client = server.accept # openning a connection and storing it in a client object we'll use to interact with the system

  request_line = client.gets # 'gets' get the first line of the request: a http method, a path and some parameters
  next if !request_line || request_line =~ /favicon/ # This will terminate the loop early if the request generates a problem, allowing us to know that the rest of our code will not need to handle these situations. Kind of a guard clause

  puts request_line # this line just prints the request_line into the consol which the code client.puts request_line sends back to the client to be displayed in the browser
  # client.puts request_line # this displays the request line to the browsers (commented out for now)

  http_method, path, params = parse_request(request_line) # Executing the helper method to parse the HTTP request, stores each element in array into separate variables

  # client.puts "HTTP/1.1 200 OK\r\n\r\n" # Before we completed the application with required status code and other fields, we needed this line to avoid problems with browsers, like Chrome, that required well-formed response

  # This section handles the response. Note that there is html embeded
  # http response status code (mandatory)
  client.puts 'HTTP/1.1. 200 OK'

  # http response header(optional)
  client.puts 'Content-Type: text/html' # The "Content-Type" header specifies how the response body is interpretated and displayed
  client.puts # An empty line is requires between the header and the body

  # http response body: html code
  client.puts '<html>'
  client.puts '<body>'
  client.puts '<pre>' # the following lines are used for debugging, to see the value of those variables printed in screen. We'll keep them inside this <pre> tag as diagnosis information. <pre> preserves the text in the way is preformated in the html file
  client.puts http_method
  client.puts path
  client.puts params
  client.puts '</pre>'

  client.puts '<h1>Rolls</h1>'

  # This section executes the business logic
  rolls = params['rolls'].to_i # everything in an http cycle is text, so sometimes we have to convert variables to integers to operate with them
  sides = params['sides'].to_i

  rolls.times do
    roll = rand(sides) + 1
    client.puts '<p>', roll, '</p>'
  end

  client.puts '</body>'
  client.puts '</html>'

  client.close
end
