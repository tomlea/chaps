require File.join(File.dirname(__FILE__), "client_helper")
require File.join(File.dirname(__FILE__), "connection_factory")

module Chaps
  module ServerHelper
    def with_authenticating_server(options = {})
      with_server(options) do |server|      
        ConnectionFactory.for(server.port) do |factory|
          def server.password_for(username)
            username unless username =~ /bad_/
          end
          yield server, factory
        end
      end
    end

    def with_server(options = {})
      server = new_server(options)
      server.start
      yield server
    ensure
      server.stop rescue nil
    end

    def new_server(options = {})
      server = Chaps::Server.new(options[:port] || 73891)
      server.audit = true if options[:audit] || options[:debug]
      server.debug = true if options[:debug]
      server
    end

    def with_client(options = {}, &block)
      with_authenticating_server(options) do |server, factory|
        factory.connect do |io|
          authenticate(io, options[:username] || "test", options[:password])
          yield server, ClientHelper.new(io)
        end
      end
    end
  end
end
