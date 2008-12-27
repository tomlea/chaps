require 'gserver'
require 'yaml'
require 'digest/md5'

module Chaps
  class Server < GServer
    def initialize(port=10001, *args)
      super(port, *args)
    end
    
    def serve(io)
      if authenticate(io)
        io << "So you managed to authenticate your client, I hope you're happy now!\n"
      end
    rescue => e
      puts "#{e.class}: #{e.message}"
      puts e.backtrace
    raise
    end
    
    def authenticate(io)
      message = expect(io, :A0)

      salt = "a"*50
      io << Messages::Outbound::A0.new(salt)
      
      username = message.username
      password = password_for(username)
      
      auth = expect(io, :A1)
      
      if password.nil?
        io << Messages::Outbound::Errors::BadUsername
        return false
      else
        if auth.md5 == Digest::MD5.hexdigest(salt + password)
          io << Messages::Outbound::A1.new
          return true
        else
          io << Messages::Outbound::Errors::BadPassword
          return false
        end
      end
    end
    
    def password_for(username)
      return "test" if username == "test"
      YAML.load(File.read("auth.yml"))[username] rescue nil
    end
    
    def expect(io, klass_name)
      raise Exception, "No such message as an #{klass_name}" unless Messages::Inbound.const_defined?(klass_name)
      message = Messages.parse(io.gets)
      raise Exception, "Expected a #{klass_name}, got a #{message.class.name}" unless message.is_a? Messages::Inbound.const_get(klass_name)
      message
    end
  end
end
