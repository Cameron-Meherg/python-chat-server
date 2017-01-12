#!/usr/bin/ruby 
require "socket"
#get the parameters for connecting
runIp = ARGV[0]
runPort = ARGV[1] 

class Client
  def initialize(server)
  	@server = server
  	@request = nil
  	@response = nil
  	listen
  	send
  	#start the send and recieve threads
  	@request.join
  	@response.join
  end

  def listen # the function used for listening to the response
  	@response = Thread.new do 
  		begin
  		while msg = @server.gets.chomp #while the stream is still running
  			
  			puts "#{msg}" #output the msg
  		end
  	rescue #if the stream is closed
  		puts "Exiting" #notify the user
  		Thread.kill @request #kill the send thread
  	end

   	end
  end
  
  def send #used for sending commands
    @request = Thread.new do
     loop{ #loop forever(or at least until the recieve thread stops us)
     	msg = $stdin.gets.chomp #get the command from the users input
     	msg = msg + "\r\n" # add the \r\n for denoting the end of the command
     	@server.puts(msg) #send it to the server
     } 	
 	end
  end
 end
 
 server = TCPSocket.open(runIp, runPort) # connect to the server
 server.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1) #set a delay cap
 Client.new( server ) # create a new client connection