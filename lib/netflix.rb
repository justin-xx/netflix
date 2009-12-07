require 'rubygems'
require 'activesupport'
# require 'oauth'
require 'hmac-sha1'
require 'open-uri'
require 'benchmark'
require 'yaml'

require 'lib/netflix/base'
require 'lib/netflix/movie'

module Netflix
  class Error < StandardError; end
end

