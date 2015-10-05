# This script should query an ip and grab a cookie and depending on the name
# return the value of the F5 network 
# use a FOR loop to go through a list of IPs 

require 'nokogiri'
require 'uri'
require 'net/https'
require 'openssl'
require 'cgi'


class Request
	attr_accessor :cookievalue
	attr_accessor :csrfToken

	def initialize(aURL,cookiename)
	@urlstring = aURL
	@cookiename = cookiename
	@csrfToken
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
	all_cookies = response.get_fields('Set-Cookie')
    		cookies_array = Array.new
    			all_cookies.each { | cookie |
			puts cookie
			if cookie.start_with?(@cookiename)
				tmp,val  = cookie.split('; ')
				 tmp,val = tmp.split('=')
				  convert(val,urlString)
			end
				}
	
	rescue 
		return 
	end  
	end
 
	def convert(value,ip)
	m = value
	oct1 = (m.to_i & 0x000000ff)
	oct2 = (m.to_i & 0x0000ffff) >> 8
	oct3 = (m.to_i & 0x00ffffff) >> 16
	oct4 = m.to_i >> 24
	port = (m[2].to_i & 0x00ff) * 256 + (m[2].to_i >> 8)
	puts "Host Address #{ip} cookie value: #{value}"
	puts "Cookie: #{value}"
	puts "Internal IP is: #{oct1}.#{oct2}.#{oct3}.#{oct4}"
	puts "Port is: #{port}"
	end 
end 
url = 'https://'<<ARGV[0] 
req = Request.new(url,ARGV[1])
req.send 

