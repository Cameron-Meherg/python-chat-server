#!/usr/bin/ruby 
require "socket"

#get the arguments for running the server
runIp = ARGV[0]
runPort = ARGV[1] 
#initiliaze the server class
class Server
  def initialize(ip, port) 
  	@server = TCPServer.open(ip,port) # open the connection on the given port
  	@helpMessage = "help<cr><lf>: recieves a respose of a list of the commands and their syntax test: words<cr><lf>: recieves a response of \"words<cr><lf\" name: <chatname><cr><lf>: recieves a response of \"OK<cr><lf>\"get<cr><lf>: recieves a response of the entire contents of the chat buffer push: <stuff><cr><lf> receives a response of \"OK<cr><lf>\" The result is that\"<chatname>: <stuff> is added as a new line to the chat buffer. getrange <startline> <endline><cr><lf> recieves a resopnse of lines <startline> through <endline> from the chat buffer. whoami<cr><lf> recieves a response of the currently set username.  time<cr><lf> returns the current time and date SOME UNRECOGNIZED COMMAND<cr><lf> recieves a response \"Error: unrecognized command: SOME UNRECOGNIZED COMMAND <cr><lf>\" adios<cr><lf> will quit the current connection.\r\n"
  	@okMessage = "OK\r\n"
  	@chats = []
  	run  # run the run function
  end
  def run
  	loop{
  		#make a thread for each incoming connection
  		Thread.start(@server.accept) do | client | 
  			begin
  			#set the username and welcome the new user
	  		username = "unknown"	
	  		client.puts "Welcome to Cameron's chat room \r\n"
	  		client.flush # make sure the welcome was sent
	  		get_message(username, client) # start accepting incoming data
	  	rescue Exception => e
	  		puts e
	  	end
  	 	end
  	}.join
  end

  def get_message(username, client)
  	#loop until the user decides to leave
  	loop{
  			
	  		leave = false # used to exit the loop set to true on adios command
	  		cont = true # used for reading in input reads until a \r\n are recieved
	  		firstspace = false # used to denoate when the first word(the command) ends
	  		msg = "" # the message sent by the user
	  		rest = "" # the rest of the message excluding the first word(the command)
	  		begin
	  		while cont # while its not a \r\n
	  			char = client.getc # get a character from the stream	  			
	  			if char == "\s" # if its a space the first word has ended
	  				firstspace = true
	  			end
	  			if char == "\r" # if its a \r
	  				char = client.getc # get the next character
	  				if char == "\n" # if thats a \n
	  					cont = false # we are at the end of this command
	  				end
	  			end
	  			msg = msg + char # add the char to the message
	  			if firstspace # if we have reached past the first word
	  				rest = rest + char # add it to the string representing the data
	  			end
	  		end
	  		#get the first command
	  		brokenUp = "#{msg}".split
	  		first = brokenUp[0]
	  		
	  		case first
	  			when "adios" # if they want to leave
	  				leave = true; # set leave to true
	  				client.shutdown(:RDWR) # shutdown the connecion
					client.close # close it
	  				break #leave
	  			when "whoami" #returns the current username
	  				toReturn = username.to_s + "\r\n"
	  				client.puts "#{toReturn}"
	  			when "time" # returns the current time
	  				time = Time.now
	  				toReturn = "Current time is " + time.inspect + "\r\n"
	  				client.puts "#{toReturn}"
	  			when "name:" #if the user wants to set a new name
	  				name = brokenUp[1] # get the new name
	  				username = name; # set it to be the username
	  				client.puts "#{@okMessage}" #send confirmation
	  				client.flush
	  			when "test:" # the user wants a string echoed back
	  				toReturn = rest.strip + "\r\n" #get the rest of the string without leading and ending spaces
	  				words = toReturn 
	  				client.puts "#{words}" #return it
	  				client.flush
	  			when "help" #send help message
	  				client.puts "#{@helpMessage}"
	  				client.flush
	  			when "get" # get teh contents of the chat buffer broken up by \n
	  				myChats = @chats.join("\n") + "\r\n"
	  				if myChats == nil # if there are no chats
	  					myChats = "\r\n" #just return the end of stream
	  				end
	  				client.puts "#{myChats}"
	  				client.flush
	  			when "push:"# add to the chats
	  				theMessage = rest.strip #get the message to add
	  				toAdd = theMessage
	  				newChat = username.to_s + ": " + toAdd #add it with the username
	  				@chats.push(newChat)
	  				client.puts "#{@okMessage}"
	  				client.flush
	  			when "getrange" #get a given range from the chat
	  				gets = brokenUp[1]
	  				gete = brokenUp[2]
	  				startline = gets.to_i #convert it to an int
	  				endline = gete.to_i
	  				range = @chats[startline...endline + 1]# get the chats from the array
	  				toReturn = range.join("\n") + "\r\n"
	  				if startline == endline && @chats[startline] != nil # if the given range is the same numbers
	  					toReturn = @chats[startline] + "\r\n"# set it to be the one line
	  				end
	  				if toReturn == nil #if there is nothing to return
	  					toReturn = "\r\n" # set it to be the end sequence
	  				end
	  				client.puts "#{toReturn}"
	  				client.flush
	  			else #otherwise it is an unrecongnized command, notify the user
	  			 client.puts "Error: unrecognized command: #{msg}\r\n"
	  			 client.flush
	  		end
	  	rescue Exception => e
	  		puts e
	  	rescue StandardError => e
	  		puts e
	  	rescue NoMemoryError => e
	  		puts e
	  	rescue Interrupt => e
	  		puts e
	  	end
	  	if leave # if we want to leave
	  		break
	  	end
	  		
	  	}
	  end
end

server = Server.new(runIp, runPort)

