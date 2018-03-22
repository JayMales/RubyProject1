require 'rubygems'
require 'nokogiri'
require 'json'

class Email
	attr_accessor :id, :first_name, :last_name, 
		:email, :gender, :ip_address, :send_date, :email_body, :email_title
	def initialize(emailarray)
		@id, @first_name, @last_name, @email, @gender, @ip_address, 
		@send_date, @email_body,@email_title = emailarray
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
			JSON.pretty_generate(obj_to_json)
		end
	end
end

emaillist = []
emails = Nokogiri::XML(File.open("emails.xml"))

emails.xpath("//record").each { |f| emaillist.push(Email.new(f.css(
		'id//text()'.to_s,'first_name//text()','last_name//text()','email//text()',
		'gender//text()','ip_address//text()','send_date//text()',
		'email_body//text()','email_title//text()')))}

emaillist.each {|e| puts e.toJson(true) if e.id.to_s.eql? "1"}