# This is a simple json request script to see payload
# generally I customize this per use 
# 

require 'uri'
require 'net/https'
require 'nokogiri'
require 'json' 


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

        
        end


end


@port = 443
@ws = "/v1/requestActivateCode"
@host = "123.123.123.123"
@payload ={"RetailTransactionRequest" => {"code" => "0000002381237220",
	"amount" => "20.00",
	"upc" => "799366289999",
	"transactionsID" => "1234",
	"dateTime" => "2015-06-02T04:47:05.208Z",
	"retailerName" => ""}
  	}.to_json
req = Net::HTTP::Post.new(@ws, initheader = {'Content-Type' =>'application/json', 'Cookie' => '_ga=GA1.1.311201852.1432051830;'})
req.body = @payload
http = Net::HTTP.new(@host, @port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.read_timeout = 100
http.set_debug_output $stdout
response = http.request(req)
puts "Response #{response.code} #{response.message}: #{response.body}"



