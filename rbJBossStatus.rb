# This script parses the JBoss status screen if available and puts it to the screen
# helpful to see calls being made to hosted JBoss applications

require 'nokogiri'
require 'uri'
require 'net/https'
require 'openssl'



class Request

	def initialize(aURL)
		@urlstring = aURL
	
	end

	def send
		urlString = @urlstring
		uri = URI.parse(urlString)
		http = Net::HTTP.new(uri.host, 443)
		request = Net::HTTP::Get.new(uri.request_uri)
		http.use_ssl = true
		http.open_timeout = 10 
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		#http.set_debug_output $stdout
		begin
			response = http.request(request)	
			#doc = Nokogiri::HTML(response.body) 
			doc = Nokogiri::XML::Reader(response.body)
			
			doc.each { | node |
			if node.name == "worker" 
				if node.attribute('stage') == "S" 
					@remoteip = node.attribute('remoteAddr') 
					@virtualhost = node.attribute('virtualHost')
					@method = node.attribute('method')
					@uri = node.attribute('currentUri')
					@qstring = node.attribute('currentQueryString')
				end 
			end
		
			x =  "URL #{@urlstring} #{@remoteip} #{@virtualhost} #{@method} #{@uri} #{@qstring}\n"	
			puts x
			output = File.open('jboss.out',"a")
			output << x
			output.close 
			}
		rescue 
			return
		end 
	end
end 

ARGV.each do | url | 
	puts url
end

url1 = 'https://'<<ARGV[0]<<"/status?XML=true"
url2 = 'https://'<<ARGV[1]<<"/status?XML=true"
req1 = Request.new(url1)
req2 = Request.new(url2)

timer = true
begin
	req1.send 
	req2.send
	sleep 5
end while timer

