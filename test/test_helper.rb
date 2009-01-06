require 'test/unit'
require File.join(File.dirname(__FILE__), *%w[.. lib chaps])
require 'rubygems'
require 'mocha'
require "timeout"

require File.join(File.dirname(__FILE__), *%w[test_helpers server_helper])


TC = Test::Unit::TestCase

class TC
  include Chaps
  include Chaps::Utils
  include Chaps::ServerHelper

  protected
  def authenticate(io, username = "test", password = nil)
    password ||= username
    io.puts "A0#{username}"
    assert(io.gets =~ /A0(.{50})/, "Did not get A0 from server when doing auth (#{username}/#{password}).")
    hash = Digest::MD5.hexdigest($1+password)
    io.puts "A1#{hash}"
    assert_match /A1.+/, io.gets, "Did not get A1 from server when doing auth (#{username}/#{password})."
  end
  
  private
  def assert_has_users(expected, server, message = nil)
    message ||= "Expected server to have <%i> users, but it has <%i>."
    sleep 0.01 #Token timeout, as connection close may not be caught otherwise
    actual = server.users.select{|u| u.online?}.size
    assert_equal expected, actual, message % [expected, actual]
  end
end

