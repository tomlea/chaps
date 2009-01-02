require 'test/unit'
require File.join(File.dirname(__FILE__), *%w[.. lib chaps])
require 'rubygems'
require 'mocha'
require "timeout"


TC = Test::Unit::TestCase

class TC
  include Chaps
  include Chaps::Utils

  protected
  class ConnectionFactory
    def initialize(port, host = "127.0.0.1")
      @port, @host = port, host
      @sockets = []
    end

    def new_client
      TCPSocket.new(@host, @port)
    end

    def connect(&block)
      sock = new_client
      if block_given?
        begin
          yield sock
        ensure
          sock.close
        end
      else
        @sockets << sock
        sock
      end
    end

    def clean_up!
      @sockets.each do |sock|
        sock.close unless sock.closed?
      end
    end
  end
  
  def authenticate(io, username = "test", password = nil)
    password ||= username
    io.puts "A0#{username}"
    assert(io.gets =~ /A0(.{50})/, "Did not get A0 from server when doing auth (#{username}/#{password}).")
    hash = Digest::MD5.hexdigest($1+password)
    io.puts "A1#{hash}"
    assert_match /A1.+/, io.gets, "Did not get A1 from server when doing auth (#{username}/#{password})."
  end
  
  def with_authenticating_server
    server = Chaps::Server.new(port = 73891)
    server.audit = false
    
    def server.password_for(username)
      username unless username =~ /bad_/
    end
    
    exit_status = nil

    server.start
    
    factory = ConnectionFactory.new(port)
    
    begin
      yield server, factory
    ensure
      server.stop rescue nil
      factory.clean_up!
    end
    server
  end
  
end

