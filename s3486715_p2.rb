require 'rubygems'
require 'nokogiri'

class Email
	attr_accessor :id, :first_name, :last_name, 
		:email, :gender, :ip_address, :send_date, :email_body, :email_title
	def initialize(emailarray)
		@id, @first_name, @last_name, @email, @gender, @ip_address, 
		@send_date, @email_body,@email_title = emailarray.map {|x| x.to_s}
	end
	def toString
		puts "id: #{@id}\nFirst Name: #{@first_name}\nLast Name: "+
		+"#{@last_name}\nEmail: #{@email}\nGender: #{@gender}\n"+
		"Ip Address: #{@ip_address}\nSend Data: #{@send_date}\n"+
		"Email Body: #{@email_body}\nEmail Title: #{@email_title}\n"
	end
	def toJson (pretty)
		obj_to_json ={'id' => @id, 'first_name'=>@first_name, 'last_name' => @last_name,
		'email'=>@email,'gender'=>@gender,'ip_address'=>@ip_address,
		'send_date'=>@send_date,'email_body'=>@email_body,
		'email_title'=>@email_title}
		if !pretty
			obj_to_json.to_json
		else
			json = "{\n"
			self.instance_variables.each do |i|
				json += "  \"#{i[1..-1]}\": #{self.instance_variable_get(i)},\n"
			end
			json += "}"
		end
	end
end

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
		exit
	end
end

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

def main(cmlInput)
	emaillist = []
	emailXML = "emails.xml"
	argm = nil

	argm = cmlInput.index("-xml")
	emailXML = cmlInput[argm+1] if argm != nil

	help(cmlInput.index("help"))

	emaillist = openFile(emaillist,emailXML)

	argm = cmlInput.index("list")
	if(argm)
		emaillist.each {|e| puts e.toJson(true) if e.ip_address.eql? 
			cmlInput[argm+2]} if cmlInput[argm+1].eql? "--ip" 
		
		emaillist.each {|e| puts e.toJson(true) if 
			e.first_name.eql? cmlInput[argm+2] or 
			e.last_name.eql? cmlInput[argm+2]} if cmlInput[argm+1].eql? "--name" 
		
		emaillist.each {|e| puts e.toJson(true) if
			e.email.eql? cmlInput[argm+2]} if cmlInput[argm+1].eql? "--email" 
	end
end

main(ARGV)