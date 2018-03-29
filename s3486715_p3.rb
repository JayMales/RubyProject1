require 'rubygems'
require 'nokogiri'
require 'date'

=begin
	Jay Males
	s3486715
	RAD Sem 1 2018
	
	For this project, I really wanted to make it "ruby".
	So I used a lot of short cuts like .each{} and sort if statments.
	I assumed that when people type in a date, it is in the format 
	yyyy-mm-dd 
=end


=begin
	This is my data structor I have made to store the data which makes it
	easier to search, print the data and stuff like that. It accepts an
	array and converts everything into a String.
=end

class Email
	attr_accessor :id, :first_name, :last_name, 
		:email, :gender, :ip_address, :send_date, :email_body, :email_title
	def initialize(emailarray)
		@id, @first_name, @last_name, @email, @gender, @ip_address, 
		@send_date, @email_body,@email_title = emailarray.map {|x| x.to_s}
	end
	# Just a toString mainly for plain text printer
	def toString
		self.instance_variables.each do |i|
			puts "#{i[1..-1]}: #{self.instance_variable_get(i)}\n"
		end
	end
=begin
	Converts all instance variables in the class into json(String). Using 
	a loop and checks for the last variable so it doesn't have a comma.
=end
	def toJson
		json = "  {\n"
		self.instance_variables.each_with_index  do |i,index|
			json += "    \"#{i[1..-1]}\": \"#{self.instance_variable_get(i)}\""
			if index != self.instance_variables.size - 1
				json += ",\n"
			else
				json += "\n"
			end
		end
		json += "  }"
	end
end

=begin
	This is my help menu, just hard coded, nothing super special
=end

def help(argm)
	if(argm)
		puts "Commands:"
		printf "%-15s %-6s %-10s # Shows the list of commands available\n", 
		File.basename(__FILE__), "help", ""
		printf "%-15s %-6s %-10s # Load a XML file\n", 
		File.basename(__FILE__), "-xml", "[filename]"
		printf "%-15s %-6s %-10s # Allows you to search\n", 
		File.basename(__FILE__), "list", ""
		printf "%-15s %-6s %-10s # Searches for ip\n", 
		"", "", "--ip"
		printf "%-15s %-6s %-10s # Searches for name(first and/or last)\n", 
		"", "", "--name"
		printf "%-15s %-6s %-10s # Searches for email\n", 
		"", "", "--email"
		printf "%-15s %-6s %-10s # Allows you to search before a date\n", 
		File.basename(__FILE__), "before", "[date]"
		printf "%-15s %-6s %-10s # Allows you to search after a date\n", 
		File.basename(__FILE__), "after", "[date]"
		printf "%-15s %-6s %-10s # Allows you to search for emails sent "+
		"on a day of the week\n",
		File.basename(__FILE__), "--day", "[day]"
		exit
	end
end

=begin
	This function opens the file, converts it into nokogiri. Then uses
	xpath to sort the xml into an array. That array becomes the instance
	variables for an email data type above. Then the email data type gets 
	pushed into an array. It also has a error check, to make sure there is
	actually a file in the location sent from main. It also checks if the
	data type fits with my object. It safely exits the program.
=end

def openFile(emaillist,emailXML)
	begin
		emails = Nokogiri::XML(File.open(emailXML))
		emails.xpath("//record").each { |f| emaillist.push(Email.new(f.css(
			'id//text()','first_name//text()','last_name//text()',
			'email//text()','gender//text()','ip_address//text()',
			'send_date//text()','email_body//text()','email_title//text()')))}
	rescue StandardError  
		puts "The file you have linked is not xml or is not found."
		exit
	end
	emaillist
end

=begin
	Just adds the commas and final brackets to the array so it is actually json
=end

def jsonFinal(aryJson)
	exit if aryJson.empty?
	finalJson = "{"
	aryJson.each do |i| 
		if aryJson.first.eql? i
			finalJson += "\n"+i.toJson
		else
			finalJson += ",\n"+i.toJson
		end
	end
	finalJson += "\n}"
end

=begin
	This is the main function. I wanted to put this into a function rather
	then just leaving this code floating in the abyss. 
	This function mainly deals with the args. It also holds the main array of
	all the email objects. 
=end

def main(cmlInput)
	emaillist,finalPrint = [],[]
	emailXML = "emails.xml"
	argm = nil

	help(cmlInput.index("help"))
	
	argm = cmlInput.index("-xml")
	emailXML = cmlInput[argm+1] if argm != nil

	emaillist = openFile(emaillist,emailXML)
	
	argm = cmlInput.index("list")
	if(argm)
		cmlValue = cmlInput[argm+2]
		finalPrint = sch(emaillist,finalPrint,cmlInput,argm,"--ip" 
		) {|e| true if e.ip_address.eql? cmlValue}
		
		finalPrint = sch(emaillist,finalPrint,cmlInput,argm,"--name" 
			) {|e| true if
			e.first_name.downcase.include? cmlValue.downcase or
			e.last_name.downcase.include? cmlValue.downcase }
		
		finalPrint = sch(emaillist,finalPrint,cmlInput,argm,"--email"
		) {|e| true if e.email == cmlValue}
		
		
		exit if finalPrint == []
	end
	
=begin
	This converts the string to a date, then uses strftime to work out
	what day it is then finds out if the input you typed in includes the 
	day.
=end
	
	argm = cmlInput.index("--day")
	if(argm)
		emaillist.each {|e| finalPrint.push(e) if Date.parse(e.send_date
		).strftime("%A").downcase.include? cmlInput[argm+1].downcase} if
		cmlInput[argm].eql? "--day"
	end
	
	finalPrint = beforeAfter(emaillist,finalPrint,cmlInput) if 
	cmlInput.index("before") != nil or cmlInput.index("after") != nil
	
	puts jsonFinal(finalPrint)
end

=begin
	This is my attempt of removing repeat code....
	But it ended up being longer then the actual code....
=end

def sch(emaillist,finalPrint,cmlInput,argm,search)
	emaillist.each {|e| finalPrint.push(e) if yield(e)} if
	cmlInput[argm+1].eql? search
	finalPrint
end

=begin
	Searches the finalPrint list for dates (before and/or after). if the 
	list is empty, then it just searches all the emails. It also checks
	if before is less then after and throws and error if that is the case
=end

def beforeAfter(emaillist,finalPrint,cmlInput)
	before,after = cmlInput.index("before"),cmlInput.index("after")

	emaillist,finalPrint = finalPrint,[] if finalPrint != [] && before != nil
	
	emaillist.each {|e| finalPrint.push(e) if e.send_date <
			cmlInput[before+1]} if before != nil
			
	if before && after
		if cmlInput[before+1] < cmlInput[after+1]
			puts "The \"before\" date has to be less then the \"after\" time."
			exit
		end
	end
	
	emaillist,finalPrint = finalPrint,[] if finalPrint != [] && after != nil

	emaillist.each {|e| finalPrint.push(e) if e.send_date >
			cmlInput[after+1]} if after != nil
			
	finalPrint
end

main(ARGV)

=begin
	Todos:
		Make a json printing function. ✓
		search dates ✓
		compare dates ✓
		upload to bitwhateveritiscalled ✓
=end