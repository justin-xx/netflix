require 'activesupport'
require 'open-uri'
require 'benchmark'
require 'yaml'
require 'oauth'

module Netflix
  class Error < StandardError; end
  class << self
    attr_accessor :base_url, :host, :protocol, :debug

    def establish_connection!
      config = YAML.load(open('oauth.yml'))
      
      # 1 - Request the not-yet-authorized request token 
      @url = "https://api.netflix.com/oauth/request_token"
      @oauth_consumer_key = config['key']
      @auth_signature_method = 'HMAC-SHA1'
      @oauth_timestamp = Time.now.to_i
      @oauth_nonce = rand(1_000_000)
      @oauth_version = '1.0' # version of Netflix API
      @oauth_signature = # The signature, a consistent reproducible concatenation of the request
      # elements into a single string. The string is used as an input in hashing or signing algorithms.
      @query_string = [@oauth_consumer_key, @oauth_signature_method,  @oauth_nonce, @oauth_timestamp, 
                       @oauth_version].join('&')
      Net::HTTP.get_print @url, "?#{@query_string}"
      

      # 2 - retry if request failed

      # Sample request
      # GET http://api.netflix.com/oauth/request_token 
      # oauth_consumer_key=4958gj86hj6g99 
      # oauth_signature_method=HMAC-SHA1 
      # oauth_timestamp=137131200 
      # oauth_nonce=4572313e48313d3d35724c31383173 
      # oauth_version=1.0

      # 3 - Exchange for an access token

    end
  end
  
  self.host = "api.netflix.com"
  self.protocol = "http"
  self.base_url = "#{protocol}://#{host}/catalog"
  self.debug = true if ENV['DEBUG']

  class Base
    def initialize(values={})
      values.each { |k, v| send "#{k}=", v }
    end
  
    class << self
      def request path
        url = URI.escape "#{Netflix.base_url}/#{path}"
        response = nil
        seconds = Benchmark.realtime { response = open url }
        puts "  \e[4;36;1mREQUEST (#{sprintf("%f", seconds)})\e[0m   \e[0;1m#{url}\e[0m" if Netflix.debug
        response.is_a?(String) ? response : response.read
      rescue OpenURI::HTTPError => e
        puts "  \e[4;36;1mREQUEST (404)\e[0m   \e[0;1m#{url}\e[0m" if Netflix.debug
        nil
      end
    
      protected
      # assuming that the uid for the artist is downcase and no spaces, this tries to match better
      def string_to_uid(str)
        str
      #  str.downcase.underscore.gsub(" ", "_")
      end
    end
    
    # Copied from ActiveRecord::Base
    def attribute_for_inspect(attr_name)
      value = send(attr_name)
  
      if value.is_a?(String) && value.length > 50
        "#{value[0..50]}...".inspect
      elsif value.is_a?(Date) || value.is_a?(Time)
        %("#{value.to_s(:db)}")
      else
        value.inspect
      end
    end
  end


end
