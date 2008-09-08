# $TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')
#require 'rubygems'
#require 'bacon'
#require 'github_post_receive_server'

# stubbing out Log's methods
require 'ipcauthpipe/log'
module IpcAuthpipe::Log
  class << self
    attr_accessor :logger
  end
end

# helper method for Array class to use in rspec's duck_type expectation
class Array
  def is_array
    true
  end
end