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
    assert_match( /A1.+/, io.gets, "Did not get A1 from server when doing auth (#{username}/#{password}).")
  end
  
  class FileSystemStub
    def initialize()
      @fake_file_system = {}
    end
    
    def open(filename, mode = "r")
      @fake_file_system[filename] ||= StringIO.new if mode == "w"
      raise Errno::ENOENT, "No such file or directory - #{filename}" unless @fake_file_system[filename]
      @fake_file_system[filename].rewind
      if block_given?
        yield @fake_file_system[filename]
      else
        @fake_file_system[filename]
      end
    end
    
    def read(filename)
      File.open(filename, "r") do |io|
        io.read
      end
    end
    
    def exist?(filename)
      @fake_file_system.has_key? filename
    end
  end
  
  def with_stubbed_file_store(&block)
    file_class = File
    Object.send :remove_const, :File
    Object.const_set(:File, FileSystemStub.new)
    yield
  ensure
    Object.send :remove_const, :File
    Object.const_set(:File, file_class)    
  end
  
  private
  def assert_has_users(expected, server, message = nil)
    message ||= "Expected server to have <%i> users, but it has <%i>."
    sleep 0.01 #Token timeout, as connection close may not be caught otherwise
    actual = server.users.select{|u| u.online?}.size
    assert_equal expected, actual, message % [expected, actual]
  end
end

